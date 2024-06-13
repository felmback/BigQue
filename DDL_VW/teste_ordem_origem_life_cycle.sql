with tb_origem as (
SELECT
concat(ID_Access,ID_Char_Reserve) as SK,
IN_Service_Provider,
ID_Access,
ID_Char_Reserve,
id_correlation
FROM `fibrasil-datalake-dev.delivery_zone.vw_ordem_origem` a
where IN_State = 'COMPLETED'
and IN_Status_code = 'OK' and IN_Status_Message = 'Ok'
and ((IN_Action = 'modify' and IN_Char_Service_State like '%active%')
  or (IN_Action = 'modify' and in_char_profile is not null and in_char_profile != '')
  or (IN_Action = 'delete')
  or (IN_Action = 'add'))
--and UPPER(id_correlation)  like '%PORTALFIBRASIL%'
)
 
select
 
tb_origem.ID_Access,
tb_origem.IN_Service_Provider,
case when tb_origem.id_correlation like '%PortalFibrasil%' then 'PORTAL'
  else 'API' end
as ORDERM_ORIGEM,
life.ID_Access,
life.SK,
tb_origem.SK as tb_origem_SK,
life.ID_Reserva
from `fibrasil-datalake-dev.delivery_zone.vw_ordem_lifecycle` life
left join tb_origem on (tb_origem.SK = life.SK  AND tb_origem.ID_Access = life.ID_Access)
--where life.ID_Access ='1000137197'
limit 100
 
 
-- select * FROM `fibrasil-datalake-dev.delivery_zone.vw_ordem_origem` a
-- where ID_Access ='1000137197'