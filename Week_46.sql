use role sysadmin;
use warehouse compute_wh;
use database frostyfriday;
create schema week_46;
use schema week_46;

create table cart_contents ( cart_number number, contents array);

insert into cart_contents ( cart_number, contents ) 
select  1 , array_construct(5,10,15,20)
UNION ALL
SELECT 2 , array_construct(8,9,10,11,12,13,14);

select * from cart_contents;

create table cart_unpack (cart_number number, content_to_remove number, order_to_remove number);

insert into cart_unpack (cart_number, content_to_remove, order_to_remove)
Values
(1,10,1),
(1,15,2),
(1,5,3),
(1,20,4),
(2,8,1),
(2,14,2),
(2,11,3),
(2,12,4),
(2,9,5),
(2,10,6),
(2,13,7);

select * from cart_unpack;

with recursive unpacking_cart as (
    select 
        cc.cart_number, 
        ARRAY_REMOVE(cc.contents,cu.content_to_remove) as current_contents_of_cart,
        cu.content_to_remove as content_last_removed,
        order_to_remove
    from cart_contents cc
    join cart_unpack cu
    on cc.cart_number = cu.cart_number
    and cu.order_to_remove = 1
    
    UNION ALL

    select 
        cc.cart_number, 
        ARRAY_REMOVE(cc.current_contents_of_cart,cu.content_to_remove) as current_contents_of_cart,
        cu.content_to_remove as content_last_removed,
        cu.order_to_remove
    from unpacking_cart cc
    join cart_unpack cu
    on cc.cart_number = cu.cart_number
    and cu.order_to_remove = cc.order_to_remove + 1
),
full_cart as (
    select
        cart_number,
        contents as current_contents_of_cart,
        null as content_last_removed,
        null as order_to_remove
    from cart_contents
)

select cart_number,current_contents_of_cart,content_last_removed from full_cart
UNION ALL
select cart_number,current_contents_of_cart,content_last_removed from unpacking_cart
;


