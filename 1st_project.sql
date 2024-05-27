-- 취소 여부에 따른 평균 가격

SELECT booking_status, AVG(avg_price_per_room) AS avg_price, COUNT(1)
FROM hotel_rsv
GROUP BY 1
ORDER BY 2 DESC