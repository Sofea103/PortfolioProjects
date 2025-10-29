/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------
--Query used by Alex. This query, the SaleDate column is still same as original. 
--A new column Sale Date Converted in created instead of updating the existing one.
/*
Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)
*/
-----------------------------------------------------------------------------------
--Standardised date format
--We will use this query instead

Select SaleDate, CONVERT(date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER COLUMN SaleDate Date;

--I did below query as I tried Alex method first, so need to remove the newly created column. 
ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDateConverted;

--------------------------------------------------------------------------------------------------------------------------
--Populate property address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--We will be doing SELF JOIN. Joining the table to itself. 
--If ParcelID is same, so PropertyAddress also should be same. 

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Use 'a' instead of update nashville as it will give error
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address --1 because we want to remove the ','
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);
--Add COLUMN PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PORTFOLIOpROJECT..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

---------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

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
From PortfolioProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress