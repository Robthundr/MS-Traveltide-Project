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
u.sign_up_date,
f.checked_bags,
h.nights

FROM sessions s
LEFT JOIN users u ON s.user_id = u.user_id
LEFT JOIN flights f ON s.trip_id = f.trip_id
LEFT JOIN hotels h ON s.trip_id = h.trip_id

WHERE
s.user_id IS NOT NULL
AND s.trip_id IS NOT NULL
AND s.page_clicks IS NOT NULL AND s.page_clicks > 0
AND s.session_start < s.session_end
AND (s.flight_discount_amount IS NULL OR s.flight_discount_amount >= 0)
AND (s.hotel_discount_amount IS NULL OR s.hotel_discount_amount >= 0)
AND (s.flight_booked = TRUE OR s.hotel_booked = TRUE)
)

SELECT
user_id,

-- Booking metrics
COUNT(DISTINCT session_id) AS total_sessions,
SUM(CASE WHEN flight_booked THEN 1 ELSE 0 END) AS flights_booked,
SUM(CASE WHEN hotel_booked THEN 1 ELSE 0 END) AS hotels_booked,
SUM(CASE WHEN flight_booked OR hotel_booked THEN 1 ELSE 0 END) AS total_bookings,

-- Cancellation
SUM(CASE WHEN cancellation THEN 1 ELSE 0 END) AS total_cancellations,
ROUND(AVG(CASE WHEN cancellation THEN 1 ELSE 0 END)::numeric, 2) AS cancellation_rate,

-- Discounts
ROUND(AVG(flight_discount_amount + hotel_discount_amount)::numeric, 2) AS avg_discount_used,

-- Engagement
ROUND(AVG(page_clicks)::numeric, 1) AS avg_page_clicks,
MIN(session_start) AS first_session,
MAX(session_end) AS last_session,

-- Perk indicators
SUM(checked_bags) AS total_checked_bags,
SUM(nights) AS total_hotel_nights

FROM session_level_enriched
GROUP BY user_id
ORDER BY user_id
LIMIT 50;

