-- /////Cleaning Data in SQL Queries/////

select *
from Portfolio_Project.dbo.nashville_housing;

-- /////Standardize the date format/////
-- Convert date and time -> date

select sale_date_converted, CONVERT(Date, SaleDate) as sale_date
from Portfolio_Project.dbo.nashville_housing;

--changing format of saledate column
Update nashville_housing
SET SaleDate = CONVERT(Date,SaleDate)

--adding a new column
ALTER TABLE nashville_housing
ADD sale_date_converted Date;

--chaning that column to have the converted sale date
Update nashville_housing
SET sale_date_converted = CONVERT(Date,SaleDate)

select sale_date_converted
from Portfolio_Project.dbo.nashville_housing;

--/////Populate Property Address Data that is NULL/////

--selecting property address column
select PropertyAddress
from Portfolio_Project.dbo.nashville_housing;

--ordering table by parcelID to use this column to fill in null values for property address column
select *
from Portfolio_Project.dbo.nashville_housing
order by ParcelID;

--joining two instances of the table to fill in null property address columns by seeing if parcelID columns match eachother
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.nashville_housing a
JOIN Portfolio_Project.dbo.nashville_housing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b. [UniqueID ]
Where a.PropertyAddress is null;

--Updating the table to get rid of the nulls
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.nashville_housing a
JOIN Portfolio_Project.dbo.nashville_housing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b. [UniqueID ]
Where a.PropertyAddress is null;

--/////Breaking Address out into individual columns (Address, City, State)/////

select PropertyAddress
from Portfolio_Project.dbo.nashville_housing;

--using substring function to start the address at the first position and end at the comma minus 1 so the comma does not show
select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))  as Address

from Portfolio_Project.dbo.nashville_housing;

--adding column to the table
ALTER TABLE nashville_housing
ADD property_split_address Nvarchar(255);

--setting values of new column to start at position 1 and end before the comma 
Update nashville_housing
SET property_split_address = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

--adding city column
ALTER TABLE nashville_housing
ADD property_split_city Nvarchar(255);

--setting city column equal to start at the comma plus 1 
Update nashville_housing
SET property_split_city = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


select *
from Portfolio_Project.dbo.nashville_housing;


--###Editing the owner address (Separating address, city and state)####

select OwnerAddress
from Portfolio_Project.dbo.nashville_housing;

--seperating the address, city and state of the property address column 
select 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from Portfolio_Project.dbo.nashville_housing;



--adding all the columns 
ALTER TABLE Portfolio_Project.dbo.nashville_housing
ADD owner_split_address Nvarchar(255);

--setting values for address
Update Portfolio_Project.dbo.nashville_housing
SET owner_split_address = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

--adding all the columns 
ALTER TABLE Portfolio_Project.dbo.nashville_housing
ADD owner_split_city Nvarchar(255);

--setting values for city
Update Portfolio_Project.dbo.nashville_housing
SET owner_split_city = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

--adding all the columns 
ALTER TABLE Portfolio_Project.dbo.nashville_housing
ADD owner_split_state Nvarchar(255); 

--setting values for state
Update Portfolio_Project.dbo.nashville_housing
SET owner_split_state = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)



--#### Changing Y and N to Yes and No in "Sold as Vacant" field ###

select Distinct (SoldAsVacant), Count(SoldAsVacant)
from Portfolio_Project.dbo.nashville_housing
Group by SoldAsVacant
order by 2

--using a case statement to change Y to YES and N to No
select SoldAsVacant, 
  CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from Portfolio_Project.dbo.nashville_housing;

--updating the actual column in the table
Update Portfolio_Project.dbo.nashville_housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- #### Removing duplicates, setting the columns to check for duplicates ###
WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY 
				   UniqueID
				   ) row_num


from Portfolio_Project.dbo.nashville_housing
)

--deleting those duplicates if row_num > 1

DELETE
from RowNumCTE
Where row_num > 1

-- Deleting unused columns

select *
from Portfolio_Project.dbo.nashville_housing;

ALTER TABLE Portfolio_Project.dbo.nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE Portfolio_Project.dbo.nashville_housing
DROP COLUMN SaleDate;


--######## MAKING CHARTS #########

--1) Average Price
select  LandUse, ROUND(AVG(SalePrice), 2) as average_price
from Portfolio_Project.dbo.nashville_housing
where LandUse = 'SINGLE FAMILY' 
      OR LandUse = 'Vacant Residential Land' 
	  OR LandUse = 'DUPLEX' 
	  OR LandUse = 'ZERO LOT LINE' 
	  OR LandUse = 'RESIDENTIAL COMBO/MISC' 
	  OR LandUse = 'TRIPLEX' 
	  OR LandUse = 'QUADPLEX' 
	  OR LandUse = 'CHURCH' 
	  OR LandUse = 'MOBILE HOME'
group by LandUse
order by average_price desc;


-------------------------------------------

--2) Average Acreage
select LandUse, ROUND(AVG(Acreage),2) as Acreage
from Portfolio_Project.dbo.nashville_housing
where LandUse = 'SINGLE FAMILY' 
      OR LandUse = 'Vacant Residential Land' 
	  OR LandUse = 'DUPLEX' 
	  OR LandUse = 'ZERO LOT LINE' 
	  OR LandUse = 'RESIDENTIAL COMBO/MISC' 
	  OR LandUse = 'TRIPLEX' 
	  OR LandUse = 'QUADPLEX' 
	  OR LandUse = 'CHURCH' 
	  OR LandUse = 'MOBILE HOME'
group by LandUse
order by Acreage desc;

---------------------------------------------

--3) Average Value
select LandUse, ROUND(AVG(TotalValue), 2) as average_value
from Portfolio_Project.dbo.nashville_housing
where LandUse = 'SINGLE FAMILY' 
      OR LandUse = 'Vacant Residential Land' 
	  OR LandUse = 'DUPLEX' 
	  OR LandUse = 'ZERO LOT LINE' 
	  OR LandUse = 'RESIDENTIAL COMBO/MISC' 
	  OR LandUse = 'TRIPLEX' 
	  OR LandUse = 'QUADPLEX' 
	  OR LandUse = 'CHURCH' 
	  OR LandUse = 'MOBILE HOME'
group by LandUse
order by average_value desc;

--4) Average Year Built
select LandUse, ROUND(AVG(YearBuilt), 0) as average_year_built
from Portfolio_Project.dbo.nashville_housing
where LandUse = 'SINGLE FAMILY' 
      OR LandUse = 'Vacant Residential Land' 
	  OR LandUse = 'DUPLEX' 
	  OR LandUse = 'ZERO LOT LINE' 
	  OR LandUse = 'RESIDENTIAL COMBO/MISC' 
	  OR LandUse = 'TRIPLEX' 
	  OR LandUse = 'QUADPLEX' 
	  OR LandUse = 'CHURCH' 
	  OR LandUse = 'MOBILE HOME'
group by LandUse
order by average_year_built desc;


-- ############# city


--BAR CHART OF CITIES

select property_split_city as city, count(property_split_city) as number_sold, LandUse as property_type
from Portfolio_Project.dbo.nashville_housing
group by property_split_city, LandUse
order by number_sold desc;

--TOTAL OF CITIES ACROSS ALL PROPERTY TYPES

--22) city
select property_split_city as city, count(property_split_city) as number_sold
from Portfolio_Project.dbo.nashville_housing
group by property_split_city
order by number_sold desc;


-- Purchases over time all types
select sale_date_converted, count(UniqueID) as number_purchased, LandUse as property_type
from Portfolio_Project.dbo.nashville_housing
group by sale_date_converted, LandUse
order by sale_date_converted asc;

-- half or full bath?

select sale_date_converted, LandUse, sum(FullBath) as full_bathroom, sum(HalfBath) as half_bathroom
from Portfolio_Project.dbo.nashville_housing
where FullBath is not NULL OR HalfBath is NOT NULL
group by LandUse, sale_date_converted;




-- FIXING PIE CHART NOT DISPLAYING CORRECT TOTALS
--SELECTING A TYPE TO SEE SALES FOR THE MOTH OF MARCH 
select count(*)
from Portfolio_Project.dbo.nashville_housing
where LandUse = 'Vacant Residential Land' AND sale_date_converted between '2015-03-01' AND '2015-03-31';

select SUM(FullBath), SUM(HalfBath)
from Portfolio_Project.dbo.nashville_housing
where LandUse = 'Vacant Residential Land' AND sale_date_converted between '2015-03-01' AND '2015-03-31';


With CTE as (
select sale_date_converted, LandUse, sum(FullBath) as full_bathroom, sum(HalfBath) as half_bathroom
from Portfolio_Project.dbo.nashville_housing
group by LandUse, sale_date_converted
)

select SUM(full_bathroom)
from CTE
where sale_date_converted LIKE '%2015-03%';

--FOUND THE PROBLEM WAS I WAS NOT FILTERING THE PIE CHART BY PROPERTY TYPE WHICH GAVE WRONG TOTALS

-- CONVERTING THE PIE CHART TOTALS TO PERCENTAGES FOR EASY VIEWING AND ADDING A PERCENT SIGN 

With Bathrooms as (
select sale_date_converted, LandUse, sum(FullBath) as full_bathroom, sum(HalfBath) as half_bathroom, SUM(FullBath) + SUM(HalfBath) as total
from Portfolio_Project.dbo.nashville_housing
group by LandUse, sale_date_converted

)

select sale_date_converted, LandUse, CONCAT(ROUND((full_bathroom / total)*100,0),'%') as full_bath_percent, CONCAT(ROUND((half_bathroom / total)*100,0),'%') as  half_bath_percent
from Bathrooms
where total is NOT NULL AND total <> 0


--FIXING CHARTS



-- REMOVING RESIDENTIAL CONDO

With Property as 
(
Select distinct(LandUse) as property_type, count(LandUse) AS count_sold
from Portfolio_Project.dbo.nashville_housing
where LandUse <> 'Residential Condo' AND LandUse <> 'VACANT ZONED MULTI FAMILY' AND LandUse <> 'FOREST' AND LandUse <> 'METRO OTHER THAN OFC, SCHOOL,HOSP, OR PARK'
Group by LandUse

)

select property_type, count_sold
from Property
where count_sold > 9;

-- VACANT RES LAND = VACANT RESIDENTIAL LAND NEED TO FIX THE NON-UNIFORM DATA

UPDATE Portfolio_Project.dbo.nashville_housing
SET LandUse ='VACANT RESIDENTIAL LAND'
WHERE LandUse ='VACANT RES LAND'

-- VACANT RESIENTIAL LAND = VACANT RESIDENTIAL LAND NEED TO FIX THE NON-UNIFORM DATA

UPDATE Portfolio_Project.dbo.nashville_housing
SET LandUse ='VACANT RESIDENTIAL LAND'
WHERE LandUse ='VACANT RESIENTIAL LAND'

select sale_date_converted
from Portfolio_Project.dbo.nashville_housing
order by sale_date_converted asc;


--DONE!!!!