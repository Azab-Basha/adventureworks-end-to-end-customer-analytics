/*
===============================================================================
DDL Script: Create Bronze Tables for AdventureWorks2025_CustomerDW
Naming Convention: bronze.aw_<schema>_<table>

AUTHOR: Azab Basha
DATE: Feb-2026
===============================================================================
*/

USE AdventureWorks2025_CustomerDW
GO

-- 1. Sales.Customer
IF OBJECT_ID('bronze.aw_sales_customer', 'U') IS NOT NULL
    DROP TABLE bronze.aw_sales_customer;
CREATE TABLE bronze.aw_sales_customer (
    customer_id int NOT NULL PRIMARY KEY,
    person_id int,
    store_id int,
    territory_id int,
    accountnumber varchar(10) NOT NULL,
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL
);

-- 2. Person.Person
IF OBJECT_ID('bronze.aw_person_person', 'U') IS NOT NULL
    DROP TABLE bronze.aw_person_person;
CREATE TABLE bronze.aw_person_person (
    business_entity_id int NOT NULL PRIMARY KEY,
    persontype nchar(2) NOT NULL,
    namestyle bit NOT NULL,
    title nvarchar(8),
    firstname nvarchar(50) NOT NULL,
    middlename nvarchar(50),
    lastname nvarchar(50) NOT NULL,
    suffix nvarchar(10),
    emailpromotion int NOT NULL,
    additionalcontactinfo xml,
    demographics xml,
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL
);

-- 3. Person.EmailAddress
IF OBJECT_ID('bronze.aw_person_emailaddress', 'U') IS NOT NULL
    DROP TABLE bronze.aw_person_emailaddress;
CREATE TABLE bronze.aw_person_emailaddress (
    business_entity_id int NOT NULL,
    emailaddress_id int NOT NULL,
    emailaddress nvarchar(50),
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL,
    PRIMARY KEY (business_entity_id, emailaddress_id)
);

-- 4. Person.Address
IF OBJECT_ID('bronze.aw_person_address', 'U') IS NOT NULL
    DROP TABLE bronze.aw_person_address;
CREATE TABLE bronze.aw_person_address (
    address_id int NOT NULL PRIMARY KEY,
    addressline1 nvarchar(60) NOT NULL,
    addressline2 nvarchar(60),
    city nvarchar(30) NOT NULL,
    stateprovince_id int NOT NULL,
    postalcode nvarchar(15) NOT NULL,
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL
);

-- 5. Person.StateProvince
IF OBJECT_ID('bronze.aw_person_stateprovince', 'U') IS NOT NULL
    DROP TABLE bronze.aw_person_stateprovince;
CREATE TABLE bronze.aw_person_stateprovince (
    stateprovince_id int NOT NULL PRIMARY KEY,
    stateprovincecode nchar(3) NOT NULL,
    countryregioncode nvarchar(3) NOT NULL,
    isonlystateprovinceflag bit NOT NULL,
    name nvarchar(50) NOT NULL,
    territory_id int NOT NULL,
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL
);

-- 6. Sales.SalesTerritory
IF OBJECT_ID('bronze.aw_sales_salesterritory', 'U') IS NOT NULL
    DROP TABLE bronze.aw_sales_salesterritory;
CREATE TABLE bronze.aw_sales_salesterritory (
    territory_id int NOT NULL PRIMARY KEY,
    name nvarchar(50) NOT NULL,
    countryregioncode nvarchar(3) NOT NULL,
    group_name nvarchar(50) NOT NULL,
    salesytd money NOT NULL,
    saleslastyear money NOT NULL,
    costytd money NOT NULL,
    costlastyear money NOT NULL,
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL
);

-- 7. Person.BusinessEntityAddress
IF OBJECT_ID('bronze.aw_person_businessentityaddress', 'U') IS NOT NULL
    DROP TABLE bronze.aw_person_businessentityaddress;
CREATE TABLE bronze.aw_person_businessentityaddress (
    business_entity_id int NOT NULL,
    address_id int NOT NULL,
    addresstype_id int NOT NULL,
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL,
    PRIMARY KEY (business_entity_id, address_id, addresstype_id)
);

-- 8. Person.AddressType
IF OBJECT_ID('bronze.aw_person_addresstype', 'U') IS NOT NULL
    DROP TABLE bronze.aw_person_addresstype;
CREATE TABLE bronze.aw_person_addresstype (
    addresstype_id int NOT NULL PRIMARY KEY,
    name nvarchar(50) NOT NULL,
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL
);

-- 9. Production.Product
IF OBJECT_ID('bronze.aw_production_product', 'U') IS NOT NULL
    DROP TABLE bronze.aw_production_product;
CREATE TABLE bronze.aw_production_product (
    product_id int NOT NULL PRIMARY KEY,
    name nvarchar(50) NOT NULL,
    productnumber nvarchar(25) NOT NULL,
    makeflag bit NOT NULL,
    finishedgoodsflag bit NOT NULL,
    color nvarchar(15),
    safetystocklevel smallint NOT NULL,
    reorderpoint smallint NOT NULL,
    standardcost money NOT NULL,
    listprice money NOT NULL,
    size nvarchar(5),
    sizeunitmeasurecode nchar(3),
    weightunitmeasurecode nchar(3),
    weight decimal(8,2),
    daystomanufacture int NOT NULL,
    productline nchar(2),
    class nchar(2),
    style nchar(2),
    productsubcategory_id int,
    productmodel_id int,
    sellstartdate datetime NOT NULL,
    sellenddate datetime,
    discontinueddate datetime,
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL
);

-- 10. Production.ProductSubcategory
IF OBJECT_ID('bronze.aw_production_productsubcategory', 'U') IS NOT NULL
    DROP TABLE bronze.aw_production_productsubcategory;
CREATE TABLE bronze.aw_production_productsubcategory (
    productsubcategory_id int NOT NULL PRIMARY KEY,
    productcategory_id int NOT NULL,
    name nvarchar(50) NOT NULL,
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL
);

-- 11. Production.ProductCategory
IF OBJECT_ID('bronze.aw_production_productcategory', 'U') IS NOT NULL
    DROP TABLE bronze.aw_production_productcategory;
CREATE TABLE bronze.aw_production_productcategory (
    productcategory_id int NOT NULL PRIMARY KEY,
    name nvarchar(50) NOT NULL,
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL
);

-- 12. Sales.SalesOrderHeader
IF OBJECT_ID('bronze.aw_sales_salesorderheader', 'U') IS NOT NULL
    DROP TABLE bronze.aw_sales_salesorderheader;
CREATE TABLE bronze.aw_sales_salesorderheader (
    salesorder_id int NOT NULL PRIMARY KEY,
    revisionnumber tinyint NOT NULL,
    orderdate datetime NOT NULL,
    duedate datetime NOT NULL,
    shipdate datetime,
    status tinyint NOT NULL,
    onlineorderflag bit NOT NULL,
    salesordernumber nvarchar(25) NOT NULL,
    purchaseordernumber nvarchar(25),
    accountnumber nvarchar(15),
    customer_id int NOT NULL,
    salesperson_id int,
    territory_id int,
    billtoaddress_id int NOT NULL,
    shiptoaddress_id int NOT NULL,
    shipmethod_id int NOT NULL,
    creditcard_id int,
    creditcardapprovalcode varchar(15),
    currencyrate_id int,
    subtotal money NOT NULL,
    taxamt money NOT NULL,
    freight money NOT NULL,
    totaldue money NOT NULL,
    comment nvarchar(128),
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL
);

-- 13. Sales.SalesOrderDetail
IF OBJECT_ID('bronze.aw_sales_salesorderdetail', 'U') IS NOT NULL
    DROP TABLE bronze.aw_sales_salesorderdetail;
CREATE TABLE bronze.aw_sales_salesorderdetail (
    salesorder_id int NOT NULL,
    salesorderdetail_id int NOT NULL,
    carriertrackingnumber nvarchar(25),
    orderqty smallint NOT NULL,
    product_id int NOT NULL,
    specialoffer_id int NOT NULL,
    unitprice money NOT NULL,
    unitpricediscount money NOT NULL,
    linetotal numeric(38,6) NOT NULL,
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL,
    PRIMARY KEY (salesorder_id, salesorderdetail_id)
);

-- 14. Sales.SpecialOffer
IF OBJECT_ID('bronze.aw_sales_specialoffer', 'U') IS NOT NULL
    DROP TABLE bronze.aw_sales_specialoffer;
CREATE TABLE bronze.aw_sales_specialoffer (
    specialoffer_id int NOT NULL PRIMARY KEY,
    description nvarchar(255) NOT NULL,
    discountpct smallmoney NOT NULL,
    type nvarchar(50) NOT NULL,
    category nvarchar(50) NOT NULL,
    startdate datetime NOT NULL,
    enddate datetime NOT NULL,
    minqty int NOT NULL,
    maxqty int,
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL
);

-- 15. Sales.SpecialOfferProduct
IF OBJECT_ID('bronze.aw_sales_specialofferproduct', 'U') IS NOT NULL
    DROP TABLE bronze.aw_sales_specialofferproduct;
CREATE TABLE bronze.aw_sales_specialofferproduct (
    specialoffer_id int NOT NULL,
    product_id int NOT NULL,
    rowguid uniqueidentifier NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL,
    PRIMARY KEY (specialoffer_id, product_id)
);

-- 16. Sales.SalesOrderHeaderSalesReason
IF OBJECT_ID('bronze.aw_sales_salesorderheadersalesreason', 'U') IS NOT NULL
    DROP TABLE bronze.aw_sales_salesorderheadersalesreason;
CREATE TABLE bronze.aw_sales_salesorderheadersalesreason (
    salesorder_id int NOT NULL,
    salesreason_id int NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL,
    PRIMARY KEY (salesorder_id, salesreason_id)
);

-- 17. Sales.SalesReason
IF OBJECT_ID('bronze.aw_sales_salesreason', 'U') IS NOT NULL
    DROP TABLE bronze.aw_sales_salesreason;
CREATE TABLE bronze.aw_sales_salesreason (
    salesreason_id int NOT NULL PRIMARY KEY,
    name nvarchar(50) NOT NULL,
    reasontype nvarchar(50) NOT NULL,
    modifieddate datetime NOT NULL,
    -- Auditing columns
    dwh_load_date datetime NOT NULL,
    dwh_batch_id varchar(100) NOT NULL
);
