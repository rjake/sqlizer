select
    room_id
    , room_number
    , hotel_id
    , hotel_name
    , n_beds
    , case when n_beds = 1 then 'single' else 'double' end as category
from
    db.admin.room
where
    hotel_id = 1
