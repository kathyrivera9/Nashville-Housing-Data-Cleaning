/*

Cleaning Data in SQL Queries
- The database was called ProjectDataCleaning

*/


Select *
From ProjectDataCleaning.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
/*
    The issue was that the SaleDate format had extra, unnecessary information. So we created a new column named SaleDateConverted where the format was updated
    and it showed just the date.
*/


Select saleDateConverted, CONVERT(Date,SaleDate)
From ProjectDataCleaning.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
/*
    The issue was that there were a few addresses that were empty/Null. So we compared the uniqueID and the parcelID to check if there were duplicated, then
    populated the empty slots with the matching addresses.
*/

Select *
From ProjectDataCleaning.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProjectDataCleaning.dbo.NashvilleHousing a
JOIN ProjectDataCleaning.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From ProjectDataCleaning.dbo.NashvilleHousing a
JOIN ProjectDataCleaning.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
/*
    The issue was that the PropertyAddress column was too hard to read since it had the whole address in the column. So using substring and charindex, 
    I split the address into two columns where one contained the address and the other contained the city. 
    Another method was used for OwnerAddress, where the parser was used to split the owneraddress in three columns containing the address, city, and state.
*/


Select PropertyAddress
From ProjectDataCleaning.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From ProjectDataCleaning.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From ProjectDataCleaning.dbo.NashvilleHousing





Select OwnerAddress
From ProjectDataCleaning.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From ProjectDataCleaning.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From ProjectDataCleaning.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
/*
	The issue was that in one column there were differently written responses. To make the data more readable and uniforomed, we replaced the Y/N into Yes/No.
	This was decided based on the fact that more Yes were written than Y
*/


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From ProjectDataCleaning.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From ProjectDataCleaning.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
/*
	The issue was that there were duplicates. In data, this is not useful as it takes up space and contains something unnecessary. There we used a CTE to see if 
	there were duplicates by checking which data had the same PropertyAddress, SalePrice, SaleDate, and LegalReference. Then those columns were deleted.
*/

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From ProjectDataCleaning.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
Order by PropertyAddress
/*
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress
*/


Select *
From ProjectDataCleaningt.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
/*
	As a result of our previous queries, there were columns that were no longer useful therefore these columns were deleted to provide a data that contains only
	useful information.
*/



Select *
From ProjectDataCleaning.dbo.NashvilleHousing


ALTER TABLE ProjectDataCleaning.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate









