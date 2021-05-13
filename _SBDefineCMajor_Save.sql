drop PROCEDURE _SBDefineCMajor_Save;

DELIMITER $$
CREATE PROCEDURE _SBDefineCMajor_Save
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
    DECLARE Var_MajorSeq			INT;
    DECLARE Var_GetDateNow			VARCHAR(100);
    DECLARE Var_InsertMajorSeq		INT;   
    DECLARE Var_SysType				VARCHAR(100);
    DECLARE Var_MajorSeqMAX			INT; 
    
	SET Var_GetDateNow  		= (SELECT DATE_FORMAT(NOW(), "%Y-%m-%d %H:%i:%s") AS GetDate); -- 작업일시는 Save되는 시점의 일시를 Insert
	SET Var_MajorSeqMAX			= (SELECT MAX(A.MajorSeq) AS MajorSeq FROM _TCBaseMAJOR AS A WHERE A.CompanySeq = 1 AND MajorSeq > 5000); -- 5000번대 이후 번호로 시스템 관리자 추가가능 (1000 ~ 4000 번호대는 총괄관리자 승인 필요)
	SET Var_SysType				= (SELECT "관리자용 정의");

	/*MajorSeq 채번*/
	 IF (Var_MajorSeqMAX IS NOT NULL) THEN 
		SET Var_InsertMajorSeq = Var_MajorSeqMAX + 1;	
     ELSE 
		SET Var_InsertMajorSeq = '5001';
     END IF;

    -- ---------------------------------------------------------------------------------------------------
    -- Insert --
	IF( InData_OperateFlag = 'S' ) THEN
		INSERT INTO _TCBaseMajor 
		( 	 
			 CompanySeq			-- 법인내부코드
			,MajorSeq			-- Major Seq
			,MajorName			-- Major 명
			,Remark				-- 메모
			,SysType			-- Major 유형
			,LastUserSeq		-- 작업자
			,LastDateTime		-- 작업일시
        )
		VALUES
		(
			 InData_CompanySeq			
			,Var_InsertMajorSeq		
			,InData_MajorName			
			,InData_Remark	
            ,Var_SysType
			,Login_UserSeq	
			,Var_GetDateNow		
		);
        
        SELECT '저장이 완료되었습니다' AS Result;

	-- ---------------------------------------------------------------------------------------------------        
    -- Delete --
	ELSEIF ( InData_OperateFlag = 'D' ) THEN  
    
		SET Var_MajorSeq = (SELECT A.MajorSeq FROM _TCBaseMajor AS A WHERE A.CompanySeq = InData_CompanySeq AND A.MajorName = InData_MajorName);  
        
		DELETE FROM _TCBaseMajor 	WHERE CompanySeq = InData_CompanySeq AND MajorSeq = Var_MajorSeq;

        SELECT '삭제되었습니다.' AS Result; 
        
	END IF;	
    
END $$
DELIMITER ;