Select *
from Project..NashvilleHousing
Order by ParcelID


--------CLEANING DATA------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

--STANDARDIZE DATE FORMAT

--converting from dateTime to just date

Select SaleDateConverted, CONVERT(Date, SaleDate) as DateWithoutTime
from Project..NashvilleHousing
Order by ParcelID

update Project..NashvilleHousing
Set SaleDate =  CONVERT(Date, SaleDate) 

ALTER TABLE Project..NashvilleHousing
Add SaleDateConverted Date;

update Project..NashvilleHousing
Set SaleDateConverted =  CONVERT(Date, SaleDate)

----------------------------------------------------------------------------------------
--POPULATE PROPERTY ADDRESS DATA---------------------------------------------
--Here we have a case where we want all properties that have the same Parcel Id to have the same adress , in this table some properties have the same 
--parcel id but one has a null and one has a property adress  , so we are population that null with the property adresses linked to the same parcel id



Select *
from Project..NashvilleHousing
Order by ParcelID

--joining the exact same table to itself where the parcel ID's are the same but not the same unique ID
--Where a.PropertyAdress is null , we will replace that null with b.propertyadress

Select a.ParcelID , a.PropertyAddress , b.ParcelID, b.PropertyAddress ,ISNULL(a.PropertyAddress, b.PropertyAddress)
from Project..NashvilleHousing a
JOIN Project..NashvilleHousing b
on a.ParcelID = b.ParcelID AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
from Project..NashvilleHousing a
JOIN Project..NashvilleHousing b
on a.ParcelID = b.ParcelID AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------
--BREAKING OUT ADRESS INTO INDIVIDUAL COLUMNS (ADRESS ,CITY , STATE)
Select PropertyAddress
from Project..NashvilleHousing

--Here we are selecting the first value in PropertyAddress Coloumn till the "," 
--using The CHARINDEX , we are marking where to stop which is by the comma ,  also shows us what position the comma is in, if we dont want to show the ";" in 
--the 'Address Coloumn" , we just say -1
--see the difference 

SELECT SUBSTRING(PropertyAddress, 1 , CHARINDEX (',',PropertyAddress)) as Address
From Project..NashvilleHousing

--So this code does not alter the table
SELECT SUBSTRING(PropertyAddress, 1 , CHARINDEX (',',PropertyAddress) -1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX (',',PropertyAddress) +1  , LEN(PropertyAddress) ) as City --City is after the comma , hence the +1
From Project..NashvilleHousing


--A code that will not alter the table when you use :
--select * 
--from Project..NashvilleHousing , so we will add a address and city coloumn

--Step 1 : Alter the table by adding a new coloumn
ALTER TABLE Project..NashvilleHousing
Add PropertySplitAddress nvarchar(255);  --table name and variable type 

--Step 2 : update the table 
update Project..NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX (',',PropertyAddress) -1) 

-----WE  DO THE SAME TO ADD THE CITY COLOUMN

--Step 1 : Alter the table by adding a new coloumn
ALTER TABLE Project..NashvilleHousing
Add PropertySplitCity nvarchar(255);  --table name and variable type 

--Step 2 : update the table 
update Project..NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX (',',PropertyAddress) +1  , LEN(PropertyAddress) )

select *
from Project..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------------------
--OWNER ADDRESS SPLIT  (using PARSENAME )

select OwnerAddress
from Project..NashvilleHousing
where OwnerAddress is not null


--we wants to split our address into 3 , PARSENAME works backwards , also our address is split by ','
select PARSENAME(REPLACE(OwnerAddress , ',' , '.' ) , 3) as Address ,
PARSENAME(REPLACE(OwnerAddress , ',' , '.' ) , 2) as City,
PARSENAME(REPLACE(OwnerAddress , ',' , '.' ) , 1) as surburb
from Project..NashvilleHousing
where OwnerAddress is not null

--Altering the table (3 coloumns)

ALTER TABLE Project..NashvilleHousing
Add OwnerSplitAddress nvarchar(255); 

update Project..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress , ',' , '.' ) , 3)


ALTER TABLE Project..NashvilleHousing
Add OwnerSplitCity nvarchar(255); 

 
update Project..NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress , ',' , '.' ) , 2)

ALTER TABLE Project..NashvilleHousing
Add OwnerSplitSurburb nvarchar(255); 

 
update Project..NashvilleHousing
Set OwnerSplitSurburb = PARSENAME(REPLACE(OwnerAddress , ',' , '.' ) , 1)

select * 
from Project..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--CHANGE Y and N To Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant) , COUNT (SoldAsVacant)
from Project..NashvilleHousing
Group by SoldAsVacant
Order by 2

Update Project..NashvilleHousing
SET SoldAsVacant = CASE 
                         WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
					END 

Select * 
from Project..NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------
--REMOVE DUPLICATES 

WITH RowNumCTE AS (
  Select * , ROW_NUMBER() OVER (PARTITION BY ParcelID , PropertyAddress, SalePrice , SaleDate , LegalReference ORDER BY UniqueID) AS Row_num

from Project..NashvilleHousing
)
 --RUN THIS FIRST , THEN COMMENT IT OUT TO RUN THE SELECT
--DELETE 
--FROM RowNumCTE
--WHERE Row_num > 1 


SELECT * 
FROM RowNumCTE
WHERE Row_num > 1 
Order by PropertyAddress

------------------------------------------------------------------------------------------------------------------------------------------------

--DELETE UNUSED COLOUMNS
Select * 
from Project..NashvilleHousing

ALTER TABLE Project..NashvilleHousing 
DROP COLUMN OwnerAddress , PropertyAddress

ALTER TABLE Project..NashvilleHousing 
DROP COLUMN SaleDate
