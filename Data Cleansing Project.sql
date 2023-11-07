/*

													--Cleaning Data Project	Via SQL Queries--

*/
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--[{START

	SELECT * 
	FROM [Project portfolio].dbo.Nashville_Housing
											       --{full view of Table}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--{1st.Upadte}
	   		   --[Standardize the  Date Format]	
									            --[Col_Name Updated using ALTER function]	

	ALTER TABLE  [Project portfolio].dbo.Nashville_Housing ALTER COLUMN SaleDate DATE

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--{2nd.Upadte}
			   --[Populate Property Address Data]
												 --[Data created using JOIN and Update Functions]

	SELECT *
	FROM [Project portfolio].dbo.Nashville_Housing
	--WHERE PropertyAddress is null
	ORDER BY ParcelID

	SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
	FROM [Project portfolio].dbo.Nashville_Housing a
	JOIN [Project portfolio].dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null
								    --[Updating Data as per the query created above to remove Null Data from PropertyAddress]

	UPDATE a
	SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
	FROM [Project portfolio].dbo.Nashville_Housing a
	JOIN [Project portfolio].dbo.Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null
								    --[Only Unique Address exists]

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--{3rd.Upadte}
			   --[Breaking out Address into Individual Col_(Address, City, State]

	--select len(PropertyAddress)
	--from [Project portfolio].dbo.Nashville_Housing                                  --{Basic Query for displaying length of the Col}
													 

	SELECT PropertyAddress
	FROM [Project portfolio].dbo.Nashville_Housing
	--WHERE PropertyAddress is not  null
	--ORDER BY ParcelID																  --{Quick View of Sorted Address Data}


---[Note]
		 --{In Substr ['1'} is used for displaying the starting position of the Char]
																			          --[CHARINDEX Function extracts a substring starting from a position in an input string with a given length]

	SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress)-1) as Address,	  --{-1} is used 			                  
	SUBSTRING(PropertyAddress, CHARINDEX(',' ,PropertyAddress)+1, LEN(PropertyAddress)) as City	
	FROM [Project portfolio].dbo.Nashville_Housing
												   --[Previously used to delimit the address data]

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--{4th. Update}

--{Altering Table to Display Delimited type Data}
												  --[Col created For Distinguished Address, City]
																								  --[Data Update into Col]

	ALTER TABLE [Project portfolio].dbo.Nashville_Housing
	ADD Property_Split_Address NVARCHAR (255);           --[Col Creation]

	UPDATE Nashville_Housing
	SET Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress)-1) 
																							      --[Column created for Property_Splot

	ALTER TABLE [Project portfolio].dbo.Nashville_Housing
	ADD property_Split_City NVARCHAR (255);			      --[Col Creation]

	UPDATE Nashville_Housing
	SET property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',' ,PropertyAddress)+1, LEN(PropertyAddress)) 
																												  --[Column created for Property's Address Splitting} --{1st Method}

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--{5th. Update}

--[Another Method to Delimit the Data]
									   --[Then filling The Col with Data]
																		  --[PARSENAME and UPDATE_SET Function used]
	SELECT 
	PARSENAME(REPLACE(OwnerAddress,',' , '.'),3),
	PARSENAME(REPLACE(OwnerAddress,',' , '.'),2),
	PARSENAME(REPLACE(OwnerAddress,',' , '.'),1)
	FROM [Project portfolio].dbo.Nashville_Housing
													--[Easiest Way to work around with Data  As a Delimiter Function]



	ALTER TABLE [Project portfolio].dbo.Nashville_Housing
	ADD Owner_Split_Address NVARCHAR (255);

	ALTER TABLE [Project portfolio].dbo.Nashville_Housing
	ADD Owner_Split_City NVARCHAR (255);
	
	ALTER TABLE [Project portfolio].dbo.Nashville_Housing
	ADD Owner_Split_State NVARCHAR (255);
										 --[Adding Owner's Data Into New Column] 
																				  --[Column Creation]


	UPDATE Nashville_Housing
	SET Owner_Split_Address =PARSENAME(REPLACE(OwnerAddress,',' , '.'),3)																							  

	UPDATE Nashville_Housing
	SET Owner_Split_City = PARSENAME(REPLACE(OwnerAddress,',' , '.'),2)
																												 
	UPDATE Nashville_Housing
	SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress,',' , '.'),1)
																	     --[Adding Data Into New Split Address Column]    

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--{6th. Update}
				--Change Y and N to Yes and No in "Sold as Vacant" 


	SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant) AS Vacant_Count                    --[Distinct and Count Values from SoldAsvacant selected]
	FROM [Project portfolio].dbo.Nashville_Housing
	GROUP BY SoldAsVacant
	ORDER BY 2
			  --[View of Vacant_Count]

	SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
	FROM [Project portfolio].dbo.Nashville_Housing
												   --[Changed Y and N to Yes and No in "Sold as Vacant" field]
																											   --[Via Case and Update_Set]

	UPDATE Nashville_Housing
	SET SoldAsVacant =CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
		--[Final Updated Column]

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--{6th. Update}
                --[Removing Duplicates]
									    --[Using CTE Function]

	WITH Row_NumCTE AS(
	SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
	FROM [Project portfolio].dbo.Nashville_Housing
	)
	SELECT *
	FROM Row_NumCTE
	WHERE row_num > 1
	ORDER BY PropertyAddress
								--[SHOWS THE DUPLICATE DATA}

	WITH Row_NumCTE AS(
	SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
	FROM [Project portfolio].dbo.Nashville_Housing
	)
	DELETE						 --[Deletes the Duplicate Data]
	FROM Row_NumCTE
	WHERE row_num > 1
	--ORDER BY PropertyAddress

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--{7th. Update}
				--[Deleting Unused Columns]
											--[Using Drop Col Function]

	SELECT *
	FROM [Project portfolio].dbo.Nashville_Housing

	ALTER TABLE [Project portfolio].dbo.Nashville_Housing
	DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

	ALTER TABLE [Project portfolio].dbo.Nashville_Housing
	DROP COLUMN SaleDate
	-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	SELECT * 
	FROM Nashville_Housing 
						   --[There You Go a much clean Data]

--END}}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------