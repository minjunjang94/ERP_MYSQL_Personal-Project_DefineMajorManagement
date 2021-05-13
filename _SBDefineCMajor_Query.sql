drop PROCEDURE _SBDefineCMajor_Query;

DELIMITER $$
CREATE PROCEDURE _SBDefineCMajor_Query
	(
		 InData_CompanySeq			INT				-- 법인내부코드
        ,InData_MajorName			VARCHAR(200)	-- Major명
		,Login_UserSeq				INT				-- 현재 로그인 중인 유저
    )
BEGIN    

	IF (InData_MajorName 	IS NULL OR InData_MajorName 	LIKE ''	) THEN	SET InData_MajorName 	= '%'; END IF;
    
    -- ---------------------------------------------------------------------------------------------------
    -- Query --
 
    set session transaction isolation level read uncommitted;  
    -- 최종조회 --
    SELECT 
		 A.CompanySeq				AS CompanySeq
		,A.MajorSeq					AS MajorSeq
		,A.MajorName				AS MajorName
		,A.Remark					AS Remark
		,A.SysType					AS SysType
		,B.UserName					AS LastUserName
		,B.UserSeq					AS LastUserSeq
		,A.LastDateTime				AS LastDateTime
	FROM _TCBaseMajor 					AS A
	LEFT OUTER JOIN _TCBaseUser			AS B    ON B.CompanySeq			= A.CompanySeq
											   AND B.UserSeq		    = A.LastUserSeq
    WHERE A.CompanySeq    			=    InData_CompanySeq
      AND A.MajorName 				LIKE InData_MajorName;

	set session transaction isolation level repeatable read;
    
END $$
DELIMITER ;