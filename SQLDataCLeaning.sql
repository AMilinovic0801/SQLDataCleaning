-- Cleaning the Data in SQL

select *
from SQLDataCleaning..NashvilleHousing


-- Standardize the Sales date format

select SaleDate, CONVERT(date, SaleDate)
from SQLDataCleaning..NashvilleHousing

-- For some reason is not working

update NashvilleHousing
set SaleDate =  CONVERT(date, SaleDate)

-- Alternate way of coverting the Sales date

alter table NashvilleHousing
add SalesDateConverted date

update NashvilleHousing
set SalesDateConverted =  CONVERT(date, SaleDate)

select SalesDateConverted
from NashvilleHousing


-- Property Adress data/ Populating the Property address by using ParcelID

select*
from NashvilleHousing
order by ParcelID

select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ],b.ParcelID, b.PropertyAddress--, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing as a
join NashvilleHousing as b
   on a.ParcelID = b.ParcelID
  and a.[UniqueID ]<> b.[UniqueID ]
--where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing as a
join NashvilleHousing as b
   on a.ParcelID = b.ParcelID
   and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

-- Breaking out PropertyAddress into individual columns (Address, City, State)

select PropertyAddress
from NashvilleHousing

-- Breaking out new columns from PropertyAddress with SUBSTRING, CHARINDEX and LEN
-- Checking if query is correct

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
from NashvilleHousing

-- Creating new rows and updating the information

alter table NashvilleHousing
add PropertyAddressSplit varchar(200)

update NashvilleHousing
set PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table NashvilleHousing
add CitySplit varchar(200)

update NashvilleHousing
set CitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- Checking if our new rows are in order

select PropertyAddressSplit, CitySplit
from NashvilleHousing



-- Splitting OwnerAddress into Address, City, State using PARSENAME

select OwnerAddress
from NashvilleHousing


select
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousing



alter table NashvilleHousing
add OwenAdressSplit varchar(200)

update NashvilleHousing
set OwenAdressSplit = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerCitySplit varchar(200)

update NashvilleHousing
set OwnerCitySplit = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OwnerStateSplit varchar(200)

update NashvilleHousing
set OwnerStateSplit = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

-- Checking if our new rows are in order

select OwenAdressSplit, OwnerCitySplit, OwnerStateSplit
from NashvilleHousing


-- Making the data uniform in the SoldAsVacant column

-- Checking how many distinct values we have, and how many per distinct value

select distinct SoldAsVacant ,COUNT(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

-- Changing the Y/N to Yes/No

update NashvilleHousing
set SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y'

update NashvilleHousing
set SoldAsVacant = 'No'
where SoldAsVacant = 'N'

-- Another way to change the values to Yes/No

update NashvilleHousing
set SoldAsVacant = 
    case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

-- Removing the duplicates

-- Using ROW_NUMBER and PARTITION to determine if we have any duplicate rows by the conditions set in the query
-- each rowNum that is greater than 2 means that row has a duplicate

with RowNumCTE as
(select *,
     ROW_NUMBER() over (Partition by ParcelID, PropertyAddress, SalePrice, SaleDate,LegalReference
	                     order by UniqueID) as rowNum
from NashvilleHousing)

-- using the CTE to delete the duplicates

--delete
--from RowNumCTE
--where rowNum > 1

-- Checking if we have any duplicates left

select *
from RowNumCTE
where rowNum > 1

-- Deleting unused columns

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

select *
from NashvilleHousing



