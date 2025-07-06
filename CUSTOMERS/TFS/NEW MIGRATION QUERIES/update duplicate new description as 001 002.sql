SELECT 
    itemcode,
    [new descripition],
    CASE 
        WHEN RN = 1 THEN [new descripition]
        ELSE [new descripition] + RIGHT('000' + CAST(RN - 1 AS VARCHAR), 3)
    END AS [new c descripition]
FROM (
    SELECT 
        itemcode,
        [new descripition],
        ROW_NUMBER() OVER (PARTITION BY [new descripition] ORDER BY itemcode) AS RN
    FROM PRODUCTLIST
) AS t
ORDER BY itemcode;



WITH RankedDuplicates AS (
    SELECT 
        itemcode,
[new descripition],
        ROW_NUMBER() OVER (PARTITION BY [new descripition] ORDER BY itemcode) AS RN
    FROM PRODUCTLIST
)
UPDATE t
SET [new descripition] = 
    CASE 
        WHEN r.RN = 1 THEN r.[new descripition]
        ELSE r.[new descripition] + RIGHT('000' + CAST(r.RN - 1 AS VARCHAR), 3)
    END
FROM PRODUCTLIST t
JOIN RankedDuplicates r ON t.itemcode = r.itemcode
