USE PortfolioProject
select * from PortfolioProject.dbo.Housing
Go


select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.Housing

Update Housing
Set SaleDate = CONVERT(Date,SaleDate)

alter table Housing
add  SaleDateConverted Date;

Update Housing
Set SaleDateConverted = CONVERT(Date,SaleDate)

select PropertyAddress from Housing
where PropertyAddress is null


select ISNULL(a.PropertyAddress,b.PropertyAddress)  
from Housing a
join Housing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)  
from Housing a
join Housing b 
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select PropertyAddress from Housing

select 
	PropertyAddress,
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) 
from Housing

alter table Housing
add PropertySplitAddress nvarchar(255);

update Housing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1);

alter table Housing
add PropertySplitCity nvarchar(255);

update Housing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress));

select OwnerAddress from Housing order by OwnerAddress desc


select PARSENAME(replace(OwnerAddress,',','.'),1),
	   PARSENAME(replace(OwnerAddress,',','.'),2),
	   PARSENAME(replace(OwnerAddress,',','.'),3) as x
from Housing order by x desc

alter table Housing
add OwnerSplitAddress nvarchar(255)

update Housing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table Housing
add OwnerSplitCity nvarchar(255)

update Housing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table Housing
add OwnerSplitState nvarchar(255)

update Housing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

select * from Housing

select distinct(SoldAsVacant),count(SoldAsVacant)
from Housing
group by SoldAsVacant
order by 2 

select SoldAsVacant,case when SoldAsVacant='Y' then 'Yes'
						when SoldAsVacant='N' then 'No'
						else SoldAsVacant
					end
from PortfolioProject.dbo.Housing

update Housing
set SoldAsVacant = case when SoldAsVacant='Y' then 'Yes'
						when SoldAsVacant='N' then 'No'
						else SoldAsVacant
					end

with RowNumCTE as
	(select *  ,
		ROW_NUMBER() over(
		Partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID
		) row_num
	from Housing
	)

--delete 
--from RowNumCTE
--where row_num > 1

select * from RowNumCTE
where row_num > 1

alter table Housing 
drop column PropertyAddress, OwnerAddress, TaxDistrict

alter table Housing 
drop column SaleDate