INSERT INTO hotel_bookings (org_id, hotel_id, city, checkin_date, checkout_date, amount, status, created_at)
SELECT ('00000000-0000-0000-0000-' || lpad((1 + ((g-1) % 5))::text, 12, '0'))::uuid,
       'hotel-' || ((g-1)%20+1), (ARRAY['delhi','mumbai','bangalore','goa','jaipur'])[((g-1)%5)+1],
       CURRENT_DATE + ((g%20)-10), CURRENT_DATE + ((g%20)-7),
       (1000 + g*17.35)::numeric(12,2), (ARRAY['confirmed','cancelled','pending','completed'])[((g-1)%4)+1],
       NOW() - ((g%45) || ' days')::interval
FROM generate_series(1,100) g;
INSERT INTO booking_events (booking_id,event_type,payload)
SELECT id, 'booking.created', jsonb_build_object('source','seed','booking_status',status)
FROM hotel_bookings WHERE id IN (SELECT id FROM hotel_bookings ORDER BY created_at DESC LIMIT 25);
