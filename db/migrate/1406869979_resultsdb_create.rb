Sequel.migration do
  change do
    create_table(:testset, :ignore_index_errors=>true) do
      primary_key :set
      String :info, :text=>true, :null=>false
      String :testdb, :text=>true, :null=>false
      String :testuser, :text=>true, :null=>false
      String :testhost, :text=>true, :null=>false
      Integer :testport, :null=>false
      String :settings, :text=>true
      foreign_key :database_uuid, :databases, :type=>String, :key=>[:uuid]

      index [:info], :name=>:testset_info_key, :unique=>true
    end

    create_table(:tests) do
      primary_key :test
      foreign_key :set, :testset, :null=>false, :key=>[:set], :on_delete=>:cascade
      Integer :scale
      Bignum :dbsize
      DateTime :start_time, :default=>Sequel::CURRENT_TIMESTAMP
      DateTime :end_time
      BigDecimal :tps, :default=>BigDecimal.new("0.0")
      String :script, :text=>true
      Integer :clients
      Integer :workers
      Integer :trans
      Float :avg_latency
      Float :max_latency
      BigDecimal :wal_written
      String :cleanup
      BigDecimal :rate_limit
    end

    create_table(:temp_test_dstat, :ignore_index_errors=>true) do
      foreign_key :test, :tests, :key=>[:test], :on_delete=>:cascade
      Float :taken_since_epoch
      String :cpu_perc_usr, :text=>true
      String :cpu_perc_sys, :text=>true
      String :cpu_perc_idle, :text=>true
      String :cpu_perc_wait, :text=>true
      String :cpu_perc_hiq, :text=>true
      String :cpu_perc_siq, :text=>true
      String :mem_used_bytes, :text=>true
      String :mem_buff_bytes, :text=>true
      String :mem_cache_bytes, :text=>true
      String :mem_free_bytes, :text=>true
      String :paging_pages_in, :text=>true
      String :paging_pages_out, :text=>true
      String :system_interrupts, :text=>true
      String :system_context_switches, :text=>true
      String :disk_read_tps, :text=>true
      String :disk_write_tps, :text=>true
      String :disk_read_requests, :text=>true
      String :disk_write_requests, :text=>true
      String :disk_read_bytes, :text=>true
      String :disk_write_bytes, :text=>true

      index [:test], :name=>:idx_temp_test_dstat
    end

    create_table(:test_bgwriter) do
      foreign_key :test, :tests, :null=>false, :key=>[:test], :on_delete=>:cascade
      Bignum :checkpoints_timed
      Bignum :checkpoints_req
      Bignum :buffers_checkpoint
      Bignum :buffers_clean
      Bignum :maxwritten_clean
      Bignum :buffers_backend
      Bignum :buffers_alloc
      Bignum :buffers_backend_fsync

      primary_key [:test]
    end

    create_table(:test_dstat, :ignore_index_errors=>true) do
      primary_key :dstatid, :type=>Bignum
      foreign_key :test, :tests, :key=>[:test], :on_delete=>:cascade
      DateTime :taken, :null=>false
      BigDecimal :cpu_perc_usr
      BigDecimal :cpu_perc_sys
      BigDecimal :cpu_perc_idle
      BigDecimal :cpu_perc_wait
      BigDecimal :cpu_perc_hiq
      BigDecimal :cpu_perc_siq
      Bignum :mem_used_bytes
      Bignum :mem_buff_bytes
      Bignum :mem_cache_bytes
      Bignum :mem_free_bytes
      Bignum :paging_pages_in
      Bignum :paging_pages_out
      Bignum :system_interrupts
      Bignum :system_context_switches
      Bignum :disk_read_tps
      Bignum :disk_write_tps
      BigDecimal :disk_read_requests
      BigDecimal :disk_write_requests
      Bignum :disk_read_bytes
      Bignum :disk_write_bytes

      index [:test], :name=>:idx_test_dstat
    end

    create_table(:timing, :ignore_index_errors=>true) do
      DateTime :ts
      Bignum :num_of_transactions
      Bignum :latency_sum
      Bignum :latency_2_sum
      Bignum :min_latency
      Bignum :max_latency
      foreign_key :test, :tests, :null=>false, :key=>[:test]

      index [:test, :ts], :name=>:idx_timing_test
    end

    execute <<-SQL
    --
    -- Convert hex value to a decimal one.  It's possible to do this using
    -- undocumented features of the bit type, such as:
    --
    --     "SELECT 'xff'::text::bit(8)::int;"
    --
    -- This function relies on that only to convert single hex digits, meaning
    -- it handles abitrarily large numbers too.  The code is inspired by the hex
    -- to decimal examples at http://postgres.cz and is not case sensitive.
    --
    -- Sample tests:
    --
    -- SELECT hex_to_dec('FF');
    -- SELECT hex_to_dec('ffff');
    -- SELECT hex_to_dec('FFff');
    -- SELECT hex_to_dec('FFFFFFFFFFFFFFFF');
    --
    CREATE OR REPLACE FUNCTION hex_to_dec (text)
    RETURNS numeric AS
    $$
    DECLARE
        r numeric;
        i int;
        digit int;
    BEGIN
        r := 0;
        FOR i in 1..length($1) LOOP
            EXECUTE E'SELECT x\''||substring($1 from i for 1)|| E'\'::integer' INTO digit;
            r := r * 16 + digit;
            END LOOP;
        RETURN r;
    END;
    $$ LANGUAGE plpgsql IMMUTABLE;

    --
    -- Process the output from pg_current_xlog_location() or
    -- pg_current_xlog_insert_location() and return a WAL Logical Serial Number
    -- from that information.  That represents an always incrementing offset
    -- within the WAL stream, proportional to how much data has been written
    -- there.  The input will look like '2/13BDE690'.
    --
    -- Sample use:
    --
    -- SELECT wal_lsn(pg_current_xlog_location());
    -- SELECT wal_lsn(pg_current_xlog_insert_location());
    --
    -- There's no error checking here.  If you input a hex string without a "/"
    -- in it, the function will process it without complaint, returning a large
    -- number as if that were the left hand side of a valid pair.
    --
    CREATE OR REPLACE FUNCTION wal_lsn (text)
    RETURNS numeric AS $$
    SELECT hex_to_dec(split_part($1,'/',1)) * 16 * 1024 * 1024 * 255
        + hex_to_dec(split_part($1,'/',2));
    $$ language sql;

    CREATE OR REPLACE FUNCTION convert_dstats(int)
    RETURNS void AS $$
    insert into test_dstat(
      test,
      taken,
      cpu_perc_usr,
      cpu_perc_sys,
      cpu_perc_idle,
      cpu_perc_wait,
      cpu_perc_hiq,
      cpu_perc_siq,
      mem_used_bytes,
      mem_buff_bytes,
      mem_cache_bytes,
      mem_free_bytes,
      paging_pages_in,
      paging_pages_out,
      system_interrupts,
      system_context_switches,
      disk_read_tps,
      disk_write_tps,
      disk_read_requests,
      disk_write_requests,
      disk_read_bytes,
      disk_write_bytes)
    select
      $1,
      to_timestamp(taken_since_epoch),
      cpu_perc_usr::numeric,
      cpu_perc_sys::numeric,
      cpu_perc_idle::numeric,
      cpu_perc_wait::numeric,
      cpu_perc_hiq::numeric,
      cpu_perc_siq::numeric,
      mem_used_bytes::numeric::bigint,
      mem_buff_bytes::numeric::bigint,
      mem_cache_bytes::numeric::bigint,
      mem_free_bytes::numeric::bigint,
      paging_pages_in::numeric::bigint,
      paging_pages_out::numeric::bigint,
      system_interrupts::numeric::bigint,
      system_context_switches::numeric::bigint,
      disk_read_tps::numeric::bigint,
      disk_write_tps::numeric::bigint,
      disk_read_requests::numeric,
      disk_write_requests::numeric,
      disk_read_bytes::numeric::bigint,
      disk_write_bytes::numeric::bigint
    from
      temp_test_dstat where test = $1;

      delete from temp_test_dstat where test = $1;

    $$ language sql;

    SQL

  end
end
