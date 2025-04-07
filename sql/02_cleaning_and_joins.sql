WITH session_level_enriched AS (
SELECT
s.session_id,
s.user_id,
s.trip_id,
s.session_start,
s.session_end,
s.flight_booked,
s.hotel_booked,
s.cancellation,
s.flight_discount,
s.flight_discount_amount,
s.hotel_discount,
s.hotel_discount_amount,
s.page_clicks,

-- User info
u.birthdate,
u.gender,
u.married,
u.has_children,
u.home_country,
u.home_city,
u.home_airport,
u.sign_up_date,

-- Flight info
f.origin_airport,
f.destination,
f.destination_airport,
f.trip_airline,
f.seats,
f.checked_bags,
f.departure_time,
f.return_time,
f.base_fare_usd,

-- Hotel info
h.hotel_name,
h.nights,
h.rooms,
h.check_in_time,
h.check_out_time,
h.hotel_per_room_usd

FROM sessions s
LEFT JOIN users u ON s.user_id = u.user_id
LEFT JOIN flights f ON s.trip_id = f.trip_id
LEFT JOIN hotels h ON s.trip_id = h.trip_id
)
SELECT *
FROM session_level_enriched
WHERE
user_id IS NOT NULL
AND trip_id IS NOT NULL
AND page_clicks IS NOT NULL AND page_clicks > 0
AND session_start < session_end
AND (flight_discount_amount IS NULL OR flight_discount_amount >= 0)
AND (hotel_discount_amount IS NULL OR hotel_discount_amount >= 0)
AND (flight_booked = TRUE OR hotel_booked = TRUE)
LIMIT 50;
