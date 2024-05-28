-- 취소 여부에 따른 평균 가격

SELECT booking_status, AVG(avg_price_per_room) AS avg_price, COUNT(1)
FROM hotel_rsv
GROUP BY 1
ORDER BY 2 DESC

-- 주중, 주말 기준 평균 가격
-- 아웃라이어로 판단될 수 있는 540과 0을 각각 제거해봤다

SELECT
	booking_status,
	case
		when no_of_weekend_nights > 0 AND no_of_week_nights > 0 then 'week & weekend'
		when no_of_weekend_nights = 0 AND no_of_week_nights > 0 then 'only week'
		when no_of_weekend_nights > 0 AND no_of_week_nights = 0 then 'only weekend'
	END AS day_of_week,
	AVG(avg_price_per_room) AS avg_price,
	COUNT(1)
FROM hotel_rsv
WHERE 1=1
AND avg_price_per_room != 540
AND avg_price_per_room != 0
GROUP BY 1, 2
ORDER BY 3 DESC