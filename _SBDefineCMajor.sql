drop PROCEDURE _SBDefineCMajor;

DELIMITER $$
CREATE PROCEDURE _SBDefineCMajor
	(
		 InData_OperateFlag		CHAR(2)			-- 작업표시
		,InData_CompanySeq		INT				-- 법인내부코드
		,InData_MajorName		VARCHAR(100)	-- (기존)Major명
		,InData_ChgMajorName	VARCHAR(100)	-- (변경)Major명
		,InData_Remark			VARCHAR(100)	-- 메모
		,Login_UserSeq			INT				-- 현재 로그인 중인 유저
    )
BEGIN
    
    DECLARE State INT;
    
    -- ---------------------------------------------------------------------------------------------------
    -- Check --
	call _SBDefineCMajor_Check
		(
			 InData_OperateFlag	
			,InData_CompanySeq	
			,InData_MajorName	
            ,InData_ChgMajorName
			,InData_Remark		
			,Login_UserSeq		
			,@Error_Check
		);
    

	IF( @Error_Check = (SELECT 9999) ) THEN
		
        SET State = 9999; -- Error 발생
        
	ELSE

	    SET State = 1111; -- 정상작동
        
		-- ---------------------------------------------------------------------------------------------------
		-- Save --
		IF( (InData_OperateFlag = 'S' OR InData_OperateFlag = 'D') AND STATE = 1111 ) THEN
			call _SBDefineCMajor_Save
				(
					 InData_OperateFlag	
					,InData_CompanySeq	
					,InData_MajorName	
                    ,InData_ChgMajorName
					,InData_Remark		
					,Login_UserSeq				
				);
		END IF;	
    
		-- ---------------------------------------------------------------------------------------------------
		-- Update --
		IF( InData_OperateFlag = 'U' AND STATE = 1111 ) THEN
			call _SBDefineCMajor_Update
				(
					 InData_OperateFlag	
					,InData_CompanySeq	
					,InData_MajorName	
                    ,InData_ChgMajorName
					,InData_Remark		
					,Login_UserSeq			
				);		
		END IF;	    

	END IF;
END $$
DELIMITER ;