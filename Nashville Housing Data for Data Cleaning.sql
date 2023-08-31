
  -- Change Date Format
  Select SaleDate, Convert(date,SaleDate) from [Nashville Housing Data]..Sheet1$

  Alter table [Nashville Housing Data]..Sheet1$
  add ConvertedSaleDate date

  Update [Nashville Housing Data]..Sheet1$
  set ConvertedSaleDate = Convert(date,SaleDate)

  Select SaleDate from [Nashville Housing Data]..Sheet1$

-- Property Address
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from [Nashville Housing Data]..Sheet1$ a
Join [Nashville Housing Data]..Sheet1$ b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set a.PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Nashville Housing Data]..Sheet1$ a
Join [Nashville Housing Data]..Sheet1$ b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

Select PropertyAddress from [Nashville Housing Data]..Sheet1$
where PropertyAddress is null

-- Separate Address and City
Alter table [Nashville Housing Data]..Sheet1$
Add Addresses nvarchar(255), City nvarchar(255)

Update [Nashville Housing Data]..Sheet1$
Set Addresses = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Update [Nashville Housing Data]..Sheet1$
Set City = Substring(PropertyAddress,charindex(',',PropertyAddress)+1 ,LEN(PropertyAddress))

Select City, Addresses from [Nashville Housing Data]..Sheet1$

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
Substring(PropertyAddress,charindex(',',PropertyAddress)+1 ,LEN(PropertyAddress)) as City
from [Nashville Housing Data]..Sheet1$
 
--Use parsename to separate address, state, city of owneraddress

Select * from [Nashville Housing Data]..Sheet1$

Alter table [Nashville Housing Data]..Sheet1$
Add OwnerSplitAddress nvarchar(255), OwnerSplitTown nvarchar(255), OwnerSplitCity nvarchar(255)

Update [Nashville Housing Data]..Sheet1$
Set OwnerSplitAddress= PARSENAME(replace(OwnerAddress,',','.'),3)

Update [Nashville Housing Data]..Sheet1$
Set OwnerSplitTown = PARSENAME(replace(OwnerAddress,',','.'),2)

Update [Nashville Housing Data]..Sheet1$
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),1)

-- Make Y to YES and N to NO
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from [Nashville Housing Data]..Sheet1$
group by SoldAsVacant
order by 2

Update [Nashville Housing Data]..Sheet1$
Set SoldAsVacant = Case when SoldAsVacant='Y' Then 'Yes'
when SoldAsVacant='N' Then 'No'
else SoldAsVacant
End

-- Remove Duplicates
with RowNumCTE as (
Select *, ROW_NUMBER() Over (Partition by
	ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference Order by UniqueID) as RowNum
from [Nashville Housing Data]..Sheet1$)

Select * from RowNumCTE
where RowNum > 1

-- Delete columns
Alter table [Nashville Housing Data]..Sheet1$
Drop column PropertyAddress, OwnerAddress, TaxDistrict 

Select * from [Nashville Housing Data]..Sheet1$

