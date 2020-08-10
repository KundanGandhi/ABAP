*&---------------------------------------------------------------------*
*& Report Z_DDIF_FIELDS_COMPARISON
*&---------------------------------------------------------------------*
*& Test
*&---------------------------------------------------------------------*
REPORT Z_DDIF_FIELDS_COMPARISON_K3.

Type-pools: slis.

Parameters: p_dtab1 type tabname default 'MC11VA0HDR',
            p_dbtab type tabname default 'VBAK'.

Data: lt_dtab1 type STANDARD TABLE OF DFIES,
      lt_dbtab type STANDARD TABLE OF DFIES,
      lt_dtab1_copy type STANDARD TABLE OF dfies,
      lt_dbtab_copy type STANDARD TABLE OF dfies,
      lt_dtab1_available type STANDARD TABLE OF dfies,
      lt_dbtab_available type STANDARD TABLE OF dfies,
      ls_dtab1 type DFIES,
      ls_dbtab type DFIES.

DATA: it_fcat type slis_t_fieldcat_alv,
     wa_fcat type slis_fieldcat_alv,
     it_layout TYPE slis_layout_alv,
     key type slis_keyinfo_alv,
     IT_EVENTS TYPE SLIS_T_EVENT,
     WA_EVENTS TYPE SLIS_ALV_EVENT.

START-OF-SELECTION.
CALL FUNCTION 'DDIF_FIELDINFO_GET'
  EXPORTING
    TABNAME              = p_dtab1
*   FIELDNAME            = ' '
   LANGU                = SY-LANGU
*   LFIELDNAME           = ' '
*   ALL_TYPES            = ' '
*   GROUP_NAMES          = ' '
*   UCLEN                =
*   DO_NOT_WRITE         = ' '
* IMPORTING
*   X030L_WA             =
*   DDOBJTYPE            =
*   DFIES_WA             =
*   LINES_DESCR          =
 TABLES
   DFIES_TAB            = lt_dtab1
*   FIXED_VALUES         =
 EXCEPTIONS
   NOT_FOUND            = 1
   INTERNAL_ERROR       = 2
   OTHERS               = 3
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

CALL FUNCTION 'DDIF_FIELDINFO_GET'
  EXPORTING
    TABNAME              = p_dbtab
*   FIELDNAME            = ' '
   LANGU                = SY-LANGU
*   LFIELDNAME           = ' '
*   ALL_TYPES            = ' '
*   GROUP_NAMES          = ' '
*   UCLEN                =
*   DO_NOT_WRITE         = ' '
* IMPORTING
*   X030L_WA             =
*   DDOBJTYPE            =
*   DFIES_WA             =
*   LINES_DESCR          =
 TABLES
   DFIES_TAB            = lt_dbtab
*   FIXED_VALUES         =
 EXCEPTIONS
   NOT_FOUND            = 1
   INTERNAL_ERROR       = 2
   OTHERS               = 3
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.

Free: lt_dtab1_available, lt_dtab1_copy.
Loop at lt_dtab1 into ls_dtab1.
  loop at lt_dbtab into ls_dbtab where fieldname eq ls_dtab1-fieldname.
*--read table is not working as well sy-subrc is not setting.
    if ls_dbtab-fieldname eq ls_dtab1-fieldname.
      Append ls_dtab1 to lt_dtab1_available.
    endif.
  endloop.
  if ls_dbtab-fieldname ne ls_dtab1-fieldname.
    Append ls_dtab1 to lt_dtab1_copy.
  endif.
  clear: ls_dbtab, ls_dtab1.
endloop.

Free: lt_dbtab_copy, lt_dbtab_available.
Loop at lt_dbtab into ls_dbtab.
  loop at lt_dtab1 into ls_dtab1 where fieldname eq ls_dbtab-fieldname.
*--read table is not working as well sy-subrc is not setting.
    if ls_dtab1-fieldname eq ls_dbtab-fieldname.
     Append ls_dbtab to lt_dbtab_available.
    endif.
  endloop.
  if ls_dtab1-fieldname ne ls_dbtab-fieldname.
    Append ls_dbtab to lt_dbtab_copy.
  endif.
  clear: ls_dbtab, ls_dtab1.
endloop.

Delete lt_dbtab where fieldname ne 'MANDT'.
*Loop at lt_dbtab_copy into ls_dbtab.
*  write: / ls_dbtab-tabname, ls_dbtab-fieldname.
*  clear: ls_dbtab.
*endloop.
*
*uline.
*
*Loop at lt_dtab1_copy into ls_dtab1.
*  write: / ls_dtab1-tabname, ls_dtab1-fieldname.
*  clear: ls_dtab1.
*endloop.

Perform create_fcat.
*perform build_layout.
*perform create_hierarchy.
perform Disp_hierarchy_alv.
end-of-selection.

*form build_layout .
**to expand the header table for item details
***  it_layout-expand_fieldname = 'TABNAME'.
**  it_layout-window_titlebar = 'Hierarchical ALV list display'.
**  it_layout-lights_tabname = 'LT_DBTAB_COPY'.
**  it_layout-colwidth_optimize = 'X'.
*
*endform.                    " build_layout

form create_fcat.
  WA_FCAT-COL_POS   = '1'.
  WA_FCAT-FIELDNAME = 'TABNAME'.
  WA_FCAT-TABNAME   = 'LT_DBTAB_COPY'.
  WA_FCAT-SELTEXT_L = 'DBTAB'.
      APPEND WA_FCAT TO IT_FCAT.
      CLEAR WA_FCAT.
  WA_FCAT-COL_POS   = '2'.
    WA_FCAT-FIELDNAME = 'FIELDNAME'.
    WA_FCAT-TABNAME   = 'LT_DBTAB_COPY'.
    WA_FCAT-SELTEXT_L = 'FIELDS'.
        APPEND WA_FCAT TO IT_FCAT.
        CLEAR WA_FCAT.


endform.

FORM TOP_PAGE.
  WRITE:/ 'Below fields are not available in', p_dtab1.
  uline.
ENDFORM.                    "TOP_PAGE

FORM TOP_THERE.
  WRITE:/ 'Below fields are available in', p_dtab1.
  uline.
ENDFORM.

FORM DISP_HIERARCHY_ALV .

*call the initial function module
CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_INIT'
  EXPORTING
    I_CALLBACK_PROGRAM             = sy-repid
*   I_CALLBACK_PF_STATUS_SET       = ' '
*   I_CALLBACK_USER_COMMAND        = ' '
*   IT_EXCLUDING                   =
          .


FREE IT_EVENTS.
WA_EVENTS-FORM = 'TOP_DESCRIPTION'.
WA_EVENTS-NAME = 'TOP_OF_PAGE'.
APPEND WA_EVENTS TO IT_EVENTS.

                   "TOP_PAGE

*call LT_DBTAB_COPY append list
CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
  EXPORTING
    IS_LAYOUT                        = IT_LAYOUT
    IT_FIELDCAT                      = IT_FCAT
    I_TABNAME                        = 'LT_DTAB1_COPY'
    IT_EVENTS                        = IT_EVENTS[]
*   IT_SORT                          =
*   I_TEXT                           = ' '
  TABLES
    T_OUTTAB                         = LT_DTAB1_COPY
 EXCEPTIONS
   PROGRAM_ERROR                    = 1
   MAXIMUM_OF_APPENDS_REACHED       = 2
   OTHERS                           = 3.

FREE IT_EVENTS.
WA_EVENTS-FORM = 'TOP_AVAILABLE'.
WA_EVENTS-NAME = 'TOP_OF_PAGE'.
APPEND WA_EVENTS TO IT_EVENTS.

CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
  EXPORTING
    IS_LAYOUT                        = IT_LAYOUT
    IT_FIELDCAT                      = IT_FCAT
    I_TABNAME                        = 'LT_DTAB1_COPY'
    IT_EVENTS                        = IT_EVENTS[]
*   IT_SORT                          =
*   I_TEXT                           = ' '
  TABLES
    T_OUTTAB                         = LT_DTAB1_AVAILABLE
 EXCEPTIONS
   PROGRAM_ERROR                    = 1
   MAXIMUM_OF_APPENDS_REACHED       = 2
   OTHERS                           = 3.



FREE IT_EVENTS.
WA_EVENTS-FORM = 'TOP_PAGE'.
WA_EVENTS-NAME = 'TOP_OF_PAGE'.
APPEND WA_EVENTS TO IT_EVENTS.

*call LT_DBTAB_COPY append list
CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
  EXPORTING
    IS_LAYOUT                        = IT_LAYOUT
    IT_FIELDCAT                      = IT_FCAT
    I_TABNAME                        = 'LT_DBTAB_COPY'
    IT_EVENTS                        = IT_EVENTS[]
*   IT_SORT                          =
*   I_TEXT                           = ' '
  TABLES
    T_OUTTAB                         = LT_DBTAB_COPY
 EXCEPTIONS
   PROGRAM_ERROR                    = 1
   MAXIMUM_OF_APPENDS_REACHED       = 2
   OTHERS                           = 3.

FREE IT_EVENTS.
WA_EVENTS-FORM = 'TOP_THERE'.
WA_EVENTS-NAME = 'TOP_OF_PAGE'.
APPEND WA_EVENTS TO IT_EVENTS.

CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_APPEND'
  EXPORTING
    IS_LAYOUT                        = IT_LAYOUT
    IT_FIELDCAT                      = IT_FCAT
    I_TABNAME                        = 'LT_DBTAB_COPY'
    IT_EVENTS                        = IT_EVENTS[]
*   IT_SORT                          =
*   I_TEXT                           = ' '
  TABLES
    T_OUTTAB                         = LT_DBTAB_available
 EXCEPTIONS
   PROGRAM_ERROR                    = 1
   MAXIMUM_OF_APPENDS_REACHED       = 2
   OTHERS                           = 3.

CALL FUNCTION 'REUSE_ALV_BLOCK_LIST_DISPLAY'
* EXPORTING
*   I_INTERFACE_CHECK             = ' '
*   IS_PRINT                      =
*   I_SCREEN_START_COLUMN         = 0
*   I_SCREEN_START_LINE           = 0
*   I_SCREEN_END_COLUMN           = 0
*   I_SCREEN_END_LINE             = 0
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER       =
*   ES_EXIT_CAUSED_BY_USER        =
* EXCEPTIONS
*   PROGRAM_ERROR                 = 1
*   OTHERS                        = 2
.

ENDFORM.                  " DISP_HIERCL_ALV

FORM TOP_DESCRIPTION.
  WRITE:/ 'Below fields are not available in', p_dbtab.
  uline.
ENDFORM.

FORM TOP_AVAILABLE.
  WRITE:/ 'Below fields are available in', p_dbtab.
  uline.
ENDFORM.
