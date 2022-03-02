-- from: https://github.com/Starmism/HotelMan/blob/445da77cb0186c08b87c07fc1194aa08a15fc393/HotelQueries.sql

select
    rm.room_id
    , rm.room_number
    , rm.hotel_id
    , ht.hotel_name
    , date(rv.checkout) - date(rv.checkin) as n_days
from
    db.admin.room                        rm
    left join db.admin.room_reservation  rr on rm.room_id         = rr.room_id
    left join db.admin.reservation       rv on rr.reservation_id  = rv.reservation_id
    left join db2.admin.hotel            ht on ht.hotel_id        = rm.hotel_id
where
    rm.hotelid = 1
;
