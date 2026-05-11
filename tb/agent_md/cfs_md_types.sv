///////////////////////////////////////////////////////////////////////////////
// File:        cfs_md_types.sv
// Author:      Cristian Florin Slav
// Date:        2023-12-30
// Description: Types used by the MD agent
///////////////////////////////////////////////////////////////////////////////
`ifndef CFS_MD_TYPES_SV
`define CFS_MD_TYPES_SV 

//MD response
typedef enum bit {
  CFS_MD_OKAY = 0,
  CFS_MD_ERR  = 1
} cfs_md_response;

`endif

