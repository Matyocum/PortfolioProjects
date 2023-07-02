--Cleaning Data in SQL Queries
---------------------------------------------------------------------------------------------------------------------------------------------

Select *
From PortfolioProject1.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------------------------------------------

--Change Sale Date

Select SaleDateConverted, CONVERT(Date,SaleDate)
From NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date



---------------------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address Data

Select *
From PortfolioProject1.dbo.NashvilleHousing
WHERE PropertyAddress is null

Select *
From PortfolioProject1.dbo.NashvilleHousing
order by  ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject1.dbo.NashvilleHousing a
JOIN PortfolioProject1.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


---------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject1.dbo.NashvilleHousing
--order by  ParcelID

--This is searching PropertyAddress for everything before the ",". This includes the comma in the returned search. To remove the comma we use the "-1".

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress))as Address
From PortfolioProject1.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255)


Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1)



ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)


Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress) +1 , LEN(PropertyAddress))

Select *
From PortfolioProject1.dbo.NashvilleHousing

Select OwnerAddress
From PortfolioProject1.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
From PortfolioProject1.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitStreet Nvarchar(255)


Update NashvilleHousing
SET OwnerSplitStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)



ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)


Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)


Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


Select *
From PortfolioProject1.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerStreetSplit

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerCitySplit

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerStateSplit

---------------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and N in "Sold as Vacant" field 

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject1.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant ='Y' THEN 'Yes'
		When SoldAsVacant ='N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject1.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant ='Y' THEN 'Yes'
		When SoldAsVacant ='N' THEN 'No'
		ELSE SoldAsVacant
		END


---------------------------------------------------------------------------------------------------------------------------------------------

---Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

From PortfolioProject1.dbo.NashvilleHousing
--ORDER BY ParcelID
)
Select *
--DELETE
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--When Deleting, the last row Order BY cannot be in the code

---------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject1.dbo.NashvilleHousing

Alter Table PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject1.dbo.NashvilleHousing
DROP COLUMN SaleDate