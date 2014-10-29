begin;

update testset
set test_type='tpc-b'
where info like 'tpc-b%'
;

update testset
set test_type='select'
where info like 'select%'
;

commit;