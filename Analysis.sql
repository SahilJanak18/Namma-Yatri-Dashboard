select * from assembly;
select * from duration;
select * from payment;
select * from trip_details;
select * from trips;

-- Total trips
select count(distinct tripid) from trip_details;

-- Checking for duplicate values in trip_details
select tripid, count(tripid) as Cnt from trip_details 
group by tripid having Cnt>1; -- (No duplicates present)

-- Total number of drivers
select count(distinct driverid) as Total_drivers from trips;

-- Total driver earnings
select sum(fare) as Total_earnings from trips;

-- Total completed trips
select count(distinct tripid) as Trips from trips;

-- Total trip searches
select sum(searches) as searches from trip_details; -- (2161)

-- total searches that got estimates (after people confirm their location)
select sum(searches_got_estimate) as searches from trip_details; -- (1758, 82.35%)

-- total searches for quotes (searching for drivers)
select sum(searches_for_quotes) as searches from trip_details; -- (1455, 82.76%)

-- total searches that got quotes( found a driver )
select sum(searches_got_quotes) as searches from trip_details; -- (1277, 87.77%)

-- trips cancelled by drivers
select count(*) - sum(driver_not_cancelled) as Drivers_cancelled from trip_details; -- (1021, 79.95%)

-- OTPs entered
select sum(otp_entered) as OTP_Entered from trip_details; -- (983, 96.28%)

-- Ride ends
select sum(end_ride) as Rides_completed from trip_details; -- (983, 100%)

-- Average distance per trip
select avg(distance) from trips; -- (14.4)

-- Average fare per trip
select avg(fare) from trips; -- (764.33)

-- Total distance travelled
select sum(distance) from trips; -- (14148)

-- Most preferred payment method
select faremethod, count(distinct tripid) as People_used from trips group by faremethod order by
People_used desc limit 1; -- ( Method 4 by 262 people)

-- To show which instrument is method 4
select method from payment a inner join (select * from trips order by fare desc limit 1) b
 on a.id=b.faremethod; -- (Here method 4 is credit card)
 
 -- For the whole day which intrument was used the most
 select method from payment a inner join (select faremethod, sum(fare) as fare from trips group by 
 faremethod order by sum(fare) desc) b on a.id=b.faremethod; -- (It's credit card)
 
 -- Which two locations had the most trips
 select * from ( select *, dense_rank() over(order by trip desc) as Rnk from (select loc_from, loc_to
 , count(distinct tripid) trip from trips group by loc_from, loc_to) a) b where Rnk=1;
 
 -- Top 5 earning drivers
 select * from( select *, dense_rank() over (order by fare desc) as rnk from (select driverid, sum(fare) 
 as fare from trips group by driverid)b)c where rnk<6;
 
 -- Which duration had more trips
SELECT * 
FROM (
    SELECT *, RANK() OVER (ORDER BY cnt DESC) AS rnk 
    FROM (
        SELECT duration, COUNT(DISTINCT tripid) AS cnt 
        FROM trips 
        GROUP BY duration
    ) c
) d 
WHERE rnk = 1; -- ( There were 53 trips of duration 1)

-- Which driver , customer pair had more orders
SELECT * 
FROM (
    SELECT *, RANK() OVER (ORDER BY cnt DESC) AS rnk 
    FROM (
        SELECT driverid, custid, COUNT(DISTINCT tripid) AS cnt 
        FROM trips 
        GROUP BY driverid, custid
    ) c
) d 
WHERE rnk = 1;

-- Search to estimate rates
select sum(searches_got_estimate)*100/sum(searches) from trip_details; -- (81.35%)

-- Estimate to search for quote rates
select sum(searches_for_quotes)*100/sum(searches_got_estimate) from trip_details; -- (82.77%)

-- Quote acceptance rate
select * from trip_details;
select sum(searches_got_quotes)*100/sum(searches_for_quotes) from trip_details; -- (87.77%)

-- Which area got the highest trips in which duration
select * from( select *, rank() over (partition by  duration order by cnt desc) rnk from
(select duration, loc_from, count(distinct tripid) as cnt from trips group by duration, loc_from)a)c
where rnk=1;

-- Which duration got the highest number of trips in each of the locations present
select * from( select *, rank() over (partition by  loc_from order by cnt desc) rnk from
(select duration, loc_from, count(distinct tripid) as cnt from trips group by duration, loc_from)a)c
where rnk=1;

 -- Which area got the highest fares
 select * from(select *, rank() over(order by fare desc) as rnk from (select loc_from, sum(fare) as fare
  from trips group by loc_from)b)c where rnk=1; -- ( Loc_from = 6 , fare = 30295)
  
 -- Which area got the highest cancellations
 select * from( select *, rank() over(order by can desc) as rnk from ( select loc_from, count(*) -
 sum(driver_not_cancelled) as can from trip_details group by loc_from)b)c where rnk=1; -- (loc=1, can=43)
 
  -- Which area got the highest trips
  select * from( select *, rank() over(order by can desc) as rnk from ( select loc_from, count(*) -
 sum(customer_not_cancelled) as can from trip_details group by loc_from)b)c where rnk=1; -- (loc=4, can=40)
 
 -- Which duration got the highest trips and fares
  select * from(select *, rank() over(order by fare desc) as rnk from (select duration, count(distinct tripid)
  as fare from trips group by duration)b)c where rnk=1; -- (duration=1, fare= 55)
 