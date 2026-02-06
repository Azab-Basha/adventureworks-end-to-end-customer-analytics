# Table Selection Methodology

This document outlines the core table shortlist and methodology based on the enhanced entity-relationship diagram (ERD) located in `docs/erd-customer-analytics-enhanced.dbml`. 

## Core Table Shortlist

- **Customer**: Represents customer information and relationships.
- **Order**: Contains order details and associations.
- **Product**: Lists products associated with orders.

## Methodology

The selection of tables was guided by the requirements outlined in the ERD document. The focus was on ensuring comprehensive coverage of customer analytics needs while maintaining performance efficiency. 

### Key Considerations
1. **Data Completeness**: Ensure all necessary entities are included.
2. **Data Quality**: Prioritize high-quality and well-defined tables.
3. **Performance**: Optimize for retrieval speeds and analytical processing.

References have been updated from `metadata.sql` to `sql/metadata-exploration-v2.sql` for consistency and accuracy in sources utilized.

## Additional References
For detailed queries and operations, refer to the accompanying `sql/metadata-exploration-v2.sql` file.