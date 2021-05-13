drop PROCEDURE _SBDefineCMajor_Update;

DELIMITER $$
CREATE PROCEDURE _SBDefineCMajor_Update
	(
		 InData_OperateFlag		CHAR(2)			-- 작업표시
		,InData_CompanySeq		INT				-- 법인내부코드
		,InData_MajorName		VARCHAR(100)	-- (기존)Major명
		,InData_ChgMajorName	VARCHAR(100)	-- (변경)Major명
		,InData_Remark			VARCHAR(100)	-- 메모
		,Login_UserSeq			INT				-- 현재 로그인 중인 유저
    )
BEGIN

	-- 변수선언
    DECLARE Var_GetDateNow			VARCHAR(100);    
    DECLARE Var_MajorSeq			INT;
    
	SET Var_GetDateNow  = (SELECT DATE_FORMAT(NOW(), "%Y-%m-%d %H:%i:%s") AS GetDate); -- 작업일시는 Update 되는 시점의 일시를 Insert
	SET Var_MajorSeq = (SELECT A.MajorSeq FROM _TCBaseMajor AS A WHERE A.CompanySeq = InData_CompanySeq AND A.MajorName = InData_MajorName);     
    
    -- ---------------------------------------------------------------------------------------------------
    -- Update --
	IF( InData_OperateFlag = 'U' ) THEN     
			UPDATE _TCBaseMajor				AS A
			   SET	 A.MajorName			= InData_ChgMajorName
					,A.Remark				= InData_Remark
				   ,A.LastUserSeq			= Login_UserSeq
				   ,A.LastDateTime			= Var_GetDateNow
			WHERE A.CompanySeq				= InData_CompanySeq 
			  AND A.MajorSeq				= Var_MajorSeq;
                     
              SELECT '저장되었습니다.' AS Result; 
                     
	ELSE
			  SELECT '저장이 완료되지 않았습니다.' AS Result;
	END IF;	


END $$
DELIMITER ;