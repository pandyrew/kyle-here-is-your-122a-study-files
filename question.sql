select distinct m.name 
from member m 
where not exists (
    (
        select b.isbn 
        from book b
        where b.publisher = 'McGrawHill'
    )
    except (
        select br.isbn 
        from borrowed br
        where br.memb_no = m.memb_no
    )
)

select m.name
from members m
where not exists (
    select 1
    from books b
    where b.publisher = "McGrawHill"
    and not exists (
        select 1
        from borrowed br
        where br.isbn = b.isbn
        and br.memb_no = m.memb_no
    )
)




