

--Extracting the whole data
select * from NewSheet..NashvilleHousing;


--Standardize Date Format
Select SaleDate
from NewSheet..NashvilleHousing;

select SaleDate,convert(Date,SaleDate)
from NewSheet..NashvilleHousing;

Update NashvilleHousing 
Set SaleDate=convert(date,SaleDate);

Alter table NashvilleHousing
add SaleDateConverted Date;

Update NashvilleHousing 
Set SaleDateConverted = convert(date,SaleDate)
select SaleDateConverted from NashvilleHousing;


-----Populate Property Address Data
Select ParcelID 
from NewSheet..NashvilleHousing
where PropertyAddress is Null;

---Populate those ParcelId address that are empty but in some other information have data in it
select A.parcelID,B.parcelID,A.propertyAddress,B.propertyAddress,
ISNULL(A.PropertyAddress,B.PropertyAddress) 
from NewSheet..NashvilleHousing as A
Join NewSheet..NashvilleHousing as B
on A.parcelID= B.parcelId 
and A.[UniqueID ]!= B.[UniqueID ]
where A.propertyaddress is null;

Update A
Set A.propertyAddress= ISNULL(A.PropertyAddress,B.PropertyAddress)
from NewSheet..NashvilleHousing as A
Join NewSheet..NashvilleHousing as B
on A.parcelID= B.parcelId 
and A.[UniqueID ]!= B.[UniqueID ]


----Breaking out Address into individual Columns(Address,City,state)
select PropertyAddress from NewSheet..NashvilleHousing;

select
Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from NewSheet..NashvilleHousing;


---Now adding split Address and city to our table;
Alter table NewSheet..NashvilleHousing 
add PropertySplitAddress Nvarchar(255);

Update NewSheet..NashvilleHousing
set PropertySplitAddress=Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) ;

Select * from NewSheet..NashvilleHousing;

Alter Table NewSheet..NashvilleHousing
add PropertyAddressCity Nvarchar(255);

Update NewSheet..NashvilleHousing
set PropertyAddressCity = Substring(PropertyAddress,Charindex(',',PropertyAddress)+1,Len(propertyAddress));



---Split OwnerAddress into city,address,state using ParseName;
select PARSENAME(Replace(OwnerAddress,',','.'),3) as Address,--ParseName take only period as the delimiter hence we have to replace the comma by period first
PARSENAME(Replace(OwnerAddress,',','.'),2) as City,
PARSENAME(Replace(OwnerAddress,',','.'),1) as state
from NewSheet..NashvilleHousing;

---Now altering the original table
Alter Table NewSheet..NashvilleHousing-- adding Owner split address
Add OwnerSplitAddress Nvarchar(255);

Update Newsheet..NashvilleHousing
set OwnerSplitAddress = Parsename(replace(owneraddress,',','.'),3);

Select * from NewSheet..NashvilleHousing;

Alter Table NewSheet..NashvilleHousing
Add OwnerSplitCity Nvarchar(255)---adding owner split city

Update Newsheet..NashvilleHousing
set OwnerSplitCity = Parsename(replace(owneraddress,',','.'),2)

Alter Table NewSheet..NashvilleHousing
Add OwnerSplitState Nvarchar(255)---adding owner split state

Update Newsheet..NashvilleHousing
set OwnerSplitState = Parsename(replace(owneraddress,',','.'),1);

------------------------------------------------------------------------------------------------------------------------------

---Change Y and N to Yes and No in "Sold as Vacant" field
select Distinct 
SoldAsVacant
from NewSheet..NashvilleHousing;

select SoldAsVacant,
case 
when SoldAsVacant='Y' then 'Yes'
When SoldAsVacant='N' then 'No'
else SoldAsVacant
end 
from NewSheet..NashvilleHousing;

Update NewSheet..NashvilleHousing
set SoldAsVacant=(
case 
when SoldAsVacant='Y' then 'Yes'
When SoldAsVacant='N' then 'No'
else SoldAsVacant
end );

Select * from NewSheet..NashvilleHousing

------------------------------------------------------------------------------------------------------------------------

----Remove Duplicates

with DuplicatesCTE as (
select * , ROW_NUMBER() over (partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference,SoldasVacant order by uniqueID) as num_row
from Newsheet..NashvilleHousing);   ----Creating a CTE where duplicates data are to be found

select * from DuplicatesCTE
where row_num > 1;

Delete * from DuplicatesCTE 
where row_num>1;




-----------------------------------------------------------------------------------------------------------------------------------
---Delete unused Columns
Select * from
NewSheet..NashvilleHousing;


Alter table NewSheet..NashvilleHousing
Drop COLUMN PropertyAddress,OwnerAddress;  


Alter table NewSheet..NashvilleHousing
Drop COLUMN SaleDAte;




















