-- How many of each change ID do these items have?
SELECT COUNT(*),
		SUM( CASE
		   	 WHEN payor_cpids_oid IS NOT NULL THEN 1
		   	 ELSE 0
		    END
		   ) as payor_cpid,
	   SUM( CASE
		   	 WHEN payer_id IS NOT NULL THEN 1
		   	 ELSE 0
		   END
		   ) as payer_id,
		SUM( CASE
		   	 WHEN cpid IS NOT NULL THEN 1
		   	 ELSE 0
			END
		   ) as cpid,
		SUM( CASE
		   	 WHEN naic_id IS NOT NULL THEN 1
		   	 ELSE 0 END
		   ) as naic
FROM change_plans
WHERE elig_exist LIKE 'Yes%'

--Will we add payer id OR change service keys?
-- TJ will ask Joyce about keys where change ids dont exist? SENT.

SELECT *
FROM change_plans

--by insurance type
--why is there no type in 72 records?
SELECT insurance_type, COUNT(*)
FROM change_plans
GROUP BY insurance_type
ORDER BY COUNT(*) desc

-- Why is aetna here?
-- Lets ask Change.
SELECT *
fROM change_plans
WHERE insurance_type IS NULL
ORDER BY payer_name
---

---- eligibility stuff
-- Tricare? What do we do with this stuff?
-- Could Bluecross be useful? Probably not.
-- 

-- why 51 null?
-- Does agreement mean we have to register with them?
-- What else could agreement mean?
-- If we do things how we are today, we can do medicaid
-- but we cannot do commercial with that npi.
-- Each plan that needs an agreement, we can register for suppliers.
-- Althea says that if they currently accept the insurance, then 
-- they are already registered and no further action is needed.
-- Let's find that in their docs or ask them directly to make our 
-- ops teams sleep better at night.
-- This is a manual process but our current api's use this magic already.
-- If it works today with eligible or ability, then it will work with chc (go cubbies).
SELECT COUNT(*), elig_exist
FROM change_plans
GROUP BY elig_exist
ORDER BY elig_exist desc;
----

-- payerid's
-- Should be for eligibility
SELECT COUNT(*), CASE 
					WHEN payer_id IS NULL THEN
						'empty'
					ELSE
						'present'
				END as payer_id
FROM change_plans
GROUP BY CASE 
					WHEN payer_id IS NULL THEN
						'empty'
					ELSE
						'present'
				END;
--


-- cpid's
-- WTF is this
SELECT COUNT(*), CASE 
					WHEN cpid IS NULL THEN
						'empty'
					ELSE
						'present'
				END as cpid
FROM change_plans
GROUP BY CASE 
					WHEN cpid IS NULL THEN
						'empty'
					ELSE
						'present'
				END;
--

--naiciDs
-- WTF is this
SELECT COUNT(*), CASE 
					WHEN naicID IS NULL THEN
						'empty'
					ELSE
						'present'
				END as naicID
FROM change_plans
GROUP BY CASE 
					WHEN naicID IS NULL THEN
						'empty'
					ELSE
						'present'
				END;
--

-- TODO: Uncover all the internal columns and what they mean.
-- Is this important to us?
-- Why or why not?
-- 201 null	
-- 3647	"Professional"
-- 3227	"Institutional"
-- Question for chc, why nulls?
-- Professional and Institutional is the format type of claims that are sent
-- Professional is basic
-- Institutational is more in depth
-- The office has to bill them in a certain way. It has nothing to do with our
-- current scope.
SELECT COUNT(*), claim_type
FROM change_plans
GROUP BY claim_type
ORDER BY claim_type desc;


-- Plan names that have more than one entry
-- for reasons like state, cpid, and claim type
SELECT payer_name, COUNT(*)
FROM change_plans
GROUP BY payer_name
HAVING COUNT(*) > 1
ORDER BY COUNT(*) desc

-- Distinct plan names with eligibility checks
-- This is the start of a query that will let us
-- start mapping things to payers ids
SELECT COUNT (DISTINCT payer_name)
FROM change_plans

WHERE elig_exist LIKE 'Yes%'

-- Need to document a gap
-- between plans without eligibility and
-- plan families. The data should help us figure that out.
-- This doesnt matter until we get to mapping/plan family "stuff"

-- How does eligible and ability data become useful to us?
-- Lets pull Tasha in here.
-- Useful to get the base information and as a sanity check if we are getting better.
-- Not useful in migrating to new plans.
-- Insurance policy stuff is whats going on here.
-- We will need to work with Tasha to understand how she consumes this right now.
