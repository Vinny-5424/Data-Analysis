/*DATA CLEANING*/

select SaleDateconverted from NashvilleHousing

/* Standardization of Date*/
--mthd 1(Just giving the right output as a new column. It does not alter the table permanently.)
Select SaleDate, Convert(Date,SaleDate) as SaleDate
from NashvilleHousing

--mthd 2(It should... It didn't)
update NashvilleHousing
set SaleDate =  Convert(Date,SaleDate)

--mthd 3(Adding new column and updating the columns)
alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted =  Convert(Date,SaleDate)  


--FILLING PROPERTY ADDRESS DATA

--Checking where Property Address is null
Select *
from NashvilleHousing
where PropertyAddress is null
order by ParcelID

--Prototype of correction
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Implementation of correction
update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]


--BREAKING OUT ADDRESS INTO COLUMNS(Address, City, State)
--Example 1(Property Address)[Using Substring method]

--Checking the context of the data in the column

Select PropertyAddress
from NashvilleHousing

-- Prototype of the corrections
Select
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Addresss,
SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress)) as Addresss
from NashvilleHousing

--Implementation of corrections

alter table NashvilleHousing
add PropertyAddressSplit nvarchar(255),

update NashvilleHousing
set PropertyAddressSplit =  SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertyCitySplit nvarchar(255)

update NashvilleHousing
set PropertyCitySplit = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))


--Example2(Owner Address)[Using Parsename method]

-- Checking

Select OwnerAddress
from NashvilleHousing

-- Drafting the template

Select 
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

--Implementation

alter table NashvilleHousing
add OwnerAddressSplit nvarchar(255)

update NashvilleHousing
set OwnerAddressSplit =  parsename(replace(OwnerAddress, ',', '.'), 3)


alter table NashvilleHousing
add OwnerCitySplit nvarchar(255)

update NashvilleHousing
set OwnerCitySplit = parsename(replace(OwnerAddress, ',', '.'), 2)


alter table NashvilleHousing
add OwnerStateSplit nvarchar(255)

update NashvilleHousing


--CHANGING "Y" & "N" TO "YES" & "NO" IN THE "SOLD AS VACANT" COLUMN

--Preview(There are some entries with 'yes' 'no')

SELECT distinct (SoldAsVacant), count(SoldAsVacant) as Number
from NashvilleHousing
group by SoldAsVacant
order by 2

--Drafting a template for corrections
Select SoldAsVacant,
case
	 when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end as NewColumn
from NashvilleHousing

--Implementation

Update NashvilleHousing
set SoldAsVacant = case
	 when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end 

-- REMOVING DUPLICATES

--Using CTE because of the kind of action to be perform.
with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
					UniqueID
					) row_num
from NashvilleHousing)
--order by ParcelID

select *
from RowNumCTE
where row_num > 1


--DELETION OF UNUSED COLUMNS
SELECT*
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate