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


-- 실 예약자 수로 성수기 판단

SELECT arrival_month, COUNT(1)
FROM hotel_rsv
WHERE booking_status = 'Not_Canceled'
GROUP BY 1
ORDER BY 2 DESC


-- 취소된 예약의 월별 평균 가격

SELECT booking_status, arrival_month, AVG(avg_price_per_room)
FROM hotel_rsv
WHERE booking_status = 'Canceled'
GROUP BY 1, 2
ORDER BY 3 DESC


-- 월별 취소율

SELECT total.arrival_month, (c.canceled_count / total.total_count) * 100 AS c_rate
FROM (
    (
        SELECT arrival_month, COUNT(1) as total_count
        FROM hotel_rsv
        GROUP BY 1
    ) AS total 
    INNER JOIN (
        SELECT arrival_month, COUNT(1) as canceled_count
        FROM hotel_rsv
        WHERE booking_status = 'Canceled'
        GROUP BY 1
    ) AS c ON total.arrival_month = c.arrival_month
)
ORDER BY 2 DESC


-- 취소 여부와 방 타입에 따른 평균 가격

SELECT booking_status, room_type_reserved, AVG(avg_price_per_room)
FROM hotel_rsv
GROUP BY 1, 2
ORDER BY 3 DESC


-- 방 타입 별 평균 인원수
-- 인당 평균 가격을 계산하기 위한 선행 코드

SELECT room_type_reserved, AVG(no_of_adults+no_of_children) AS avg_num
FROM hotel_rsv
GROUP BY 1


-- 방 타입 별 취소율, 인당 가격, 평균 인원수, 특별 요청 건수를 한꺼번에 나타냈다
-- 인당 가격이 아닌 그냥 평균 가격을 보려면 3번째 줄을 c.avg_price로 바꾸면 된다

SELECT total.room_type_reserved,
	(c.cancel_cnt / total.total_cnt) * 100 AS c_rate,
	(c.avg_price / num.avg_num) AS one_price,
	num.avg_num, request.num_request
FROM (
		(
			SELECT room_type_reserved, COUNT(1) AS total_cnt
			FROM hotel_rsv
			GROUP BY 1
		) AS total
		INNER JOIN (
			SELECT room_type_reserved, COUNT(1) AS cancel_cnt, AVG(avg_price_per_room) AS avg_price
			FROM hotel_rsv
			WHERE booking_status = 'Canceled'
			GROUP BY 1
		) AS c ON total.room_type_reserved = c.room_type_reserved
		INNER JOIN (
			SELECT room_type_reserved, AVG(no_of_adults+no_of_children) AS avg_num
			FROM hotel_rsv
			GROUP BY 1
		) AS num ON c.room_type_reserved = num.room_type_reserved
		INNER JOIN (
			SELECT room_type_reserved, AVG(no_of_special_requests) AS num_request
			FROM hotel_rsv
			GROUP BY 1
		) AS request ON c.room_type_reserved = request.room_type_reserved
	)
ORDER BY 3 DESC


-- 예약수단 별 평균 가격과 취소율
-- 가격에 변수가 많은 corporate, complementary, aviation을 제외하고 online, offline만 비교

SELECT c.market_segment_type,
		c.avg_price,
		(c.cnt_c / t.cnt_t) * 100 AS per_c
FROM (
	(
		SELECT market_segment_type,
			AVG(avg_price_per_room) AS avg_price,
			COUNT(1) AS cnt_c
		FROM hotel_rsv
		WHERE booking_status = 'Canceled'
		GROUP BY 1
	) AS c
	INNER JOIN (
		SELECT market_segment_type,
			COUNT(1) AS cnt_t
		FROM hotel_rsv
		GROUP BY 1
	) AS t ON c.market_segment_type = t.market_segment_type
)
WHERE c.market_segment_type IN ('online', 'offline')
ORDER BY 2 DESC


-- 취소 여부에 따른 평균 예약과 입실 사이 기간과 평균 가격

SELECT booking_status, AVG(lead_time), AVG(avg_price_per_room)
FROM hotel_rsv
GROUP BY 1
ORDER BY 3 DESC 
