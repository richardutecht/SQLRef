# This SQL will take a source Json column of key value pairs and then return them for use in a dynamic pivot table

CREATE TEMPORARY TABLE AttributesTMP (
    ID INT,
    PersonID INT,
    AttributeKey VARCHAR(250),
    AttributeValue VARCHAR(250)
);

INSERT AttributesTMP 
    SELECT
        ID,
        PersonID,
        CONCAT( REPLACE( REPLACE ( REPLACE ( JSON_KEYS(Attributes),'", "', ','),'["',''),'"]', ''), ',') as AttributeKey,
        Attributes as AttributeValue
        FROM PeopleWithAttributes; # Can Add Where clause here to limit the data set

WITH recursive flattenAttributes(ID, PersonID, AttrKey, AttrValue, AttributeKey, AttributeValue) AS (
    SELECT
        ID,
        PersonID,
        SUBSTRING_INDEX(AttributeKey, ',', 1),
        JSON_UNQUOTE(JSON_EXTRACT(AttributeValue, CONCAT('$.', SUBSTRING_INDEX(AttributeKey, ',', 1)))) as 'AttrValue',
        REPLACE(AttributeKey,CONCAT(SUBSTRING_INDEX(AttributeKey, ',', 1), ','), ''),
        AttributeValue
        FROM AttributesTMP
    
    UNION ALL
    
    SELECT
        ID,
        PersonID,
        SUBSTRING_INDEX(AttributeKey, ',', 1),
        JSON_UNQUOTE(JSON_EXTRACT(AttributeValue, CONCAT('$.', SUBSTRING_INDEX(AttributeKey, ',', 1)))) as 'AttrValue',
        REPLACE(AttributeKey, CONCAT(SUBSTRING_INDEX(AttributeKey, ',', 1), ','), ''),
        AttributeValue
        FROM flattenAttributes
        WHERE
            AttributeKey > ''
)
SELECT
    ID,
    PersonID,
    AttrKey,
    AttrValue
    FROM flattenAttributes
    ORDER BY ID;


# Setup Sample table
    
CREATE TABLE `peoplewithattributes` (
  `ID` int NOT NULL,
  `PersonID` int DEFAULT NULL,
  `Attributes` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

INSERT INTO `peoplewithattributes`
(`ID`,
`PersonID`,
`Attributes`)
VALUES
(2,1,'{"Fruit":"Apple","Dessert":"Pie"}'),
(3,2,'{"Fruit":"Oranges","Car":"Honda"}');