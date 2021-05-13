drop PROCEDURE _SBDefineCMajor_Check;

DELIMITER $$
CREATE PROCEDURE _SBDefineCMajor_Check
	(
		 InData_OperateFlag		CHAR(2)			-- 작업표시
		,InData_CompanySeq		INT				-- 법인내부코드
		,InData_MajorName		VARCHAR(100)	-- (기존)Major명
		,InData_ChgMajorName	VARCHAR(100)	-- (변경)Major명
		,InData_Remark			VARCHAR(100)	-- 메모
		,Login_UserSeq			INT				-- 현재 로그인 중인 유저
        ,OUT RETURN_OUT INT						-- IsCheck 결과 내보내기
    )
Error_Out:BEGIN -- Error_Out : 오류가 발생했을 경우 프로시져 종료

	-- 오류 관리 변수---------------------------------------
	DECLARE CompanySeq 			INT;
	DECLARE IsCheck 			INT;
    DECLARE Result  			VARCHAR(1000);
	-- -------------------------------------------------
    
    -- 변수선언 --    
    DECLARE Var_MajorSeq 	INT;    
    
	-- 변수설정 --
	SET Var_MajorSeq = (SELECT A.MajorSeq FROM _TCBaseMajor AS A WHERE A.CompanySeq = InData_CompanySeq AND A.MajorName = InData_MajorName);	
    
    
	-- 오류 관리 테이블---------------------------------------
	CREATE TEMPORARY TABLE IsCheck_TEMP
    (CompanySeq INT, IsCheck INT, Result VARCHAR(500));
	INSERT INTO IsCheck_TEMP VALUES(InData_CompanySeq, 1111, '');    
	-- -------------------------------------------------	
	
    -- OperateFlag의 값이 'S', 'U', 'D' 외의 값이 들어갈 경우 에러발생------------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.MajorSeq, 1111)  	  AS MajorSeq 
				FROM _TCBaseMajor 		  	  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON InData_OperateFlag <> 'S'
                RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_2  ON InData_OperateFlag <> 'U'
                RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_3  ON InData_OperateFlag <> 'D'
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '[ (S) : 저장 , (U) : 업데이트 , (D) : 삭제 ] 외의 명령을 입력할 수 없습니다.';
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;  



 	-- InData_CompanySeq, InData_MajorName 를 필수로 입력하지 않을 경우 에러발생 ------------------------------------------------
     IF ((SELECT IFNULL(A.ERR, 1111)    	  AS MajorSeq 
				FROM (SELECT 9999 AS ERR)	  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON (
																	   (InData_CompanySeq		   	= 0 )  
																	OR (InData_MajorName       		= '')
																 )   
															  AND (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U')
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE    
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '법인내부코드, Major명 는 필수값 입니다.'
	   WHERE (InData_OperateFlag LIKE 'S' OR InData_OperateFlag LIKE 'U');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);      
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF; -- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;   



    -- InData_CompanySeq의 값이 _TSBaseCompany.CompanySeq의 데이터에 존재하는 값이 없을 경우 에러발생 ------------------------------------------------------------------------------
    IF ((SELECT IFNULL(A.CompanySeq, 1111)  	AS CompanySeq 
				FROM _TSBaseCompany 		  	AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON  (InData_CompanySeq  <>    	A.CompanySeq ) 
															  AND (InData_OperateFlag LIKE      'S'			 )
		 limit 1
         ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
        
    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '등록된 법인 정보가 아닙니다. 법인등록을 해주세요.'
	   WHERE (InData_OperateFlag LIKE 'S');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;  
    
    

    -- 업데이트와 삭제 시 데이터가 없을 경우 에러발생 ------------------------------------------------------------------------------------------------  
    IF ((SELECT IFNULL(A.MajorSeq, 1111)      AS MajorSeq 
				FROM _TCBaseMajor 		      AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq     =       InData_CompanySeq
															 AND A.MajorName      =       InData_MajorName
															 AND (InData_OperateFlag LIKE 'U' OR InData_OperateFlag LIKE 'D')
		 limit 1
         ) = (SELECT Var_MajorSeq))  -- 데이터가 존재하다면 수정하려는 Seq가 같은지 여부 확인
	THEN

	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
       
	ELSEIF InData_OperateFlag = 'S' -- Save일 경우 해당 체크가 영향 안받도록 추가
	THEN
		-- TRUE
	   SET CompanySeq = InData_CompanySeq;	
       
    ELSE
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '데이터가 존재하지 않습니다.'
	   WHERE (InData_OperateFlag LIKE 'U' OR InData_OperateFlag LIKE 'D');
       -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
       LEAVE Error_Out; -- 프로시져 종료
       -- ------------------------------------------------------------------------------------
    END IF;    
    


	-- Update할 경우 InData_ChgMajorName 데이터가 같은 _TCBaseMajor.MajorSeq 기준으로  _TCBaseMajor.MajorName과 중복되거나 빈값일 경우 에러발생----------------------------------------------------------------------------
    IF ((SELECT A.MajorSeq FROM _TCBaseMajor AS A WHERE A.CompanySeq = InData_CompanySeq AND A.MajorName = InData_ChgMajorName) = (SELECT Var_MajorSeq)) -- 기존 MinorName이 업데이트되면 정상처리
    THEN    
 	   SET CompanySeq = InData_CompanySeq;   
    ELSE 
		IF ((SELECT IFNULL(A.MajorSeq	, 1111)   AS MajorSeq 
					FROM _TCBaseMajor	 		  AS A 
					RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =    InData_CompanySeq
																 AND (
																			A.MajorName    	=    InData_ChgMajorName
																		OR  InData_ChgMajorName LIKE ''
																	 )
																 AND (InData_OperateFlag LIKE 'U') 
			limit 1
		     ) = (SELECT 1111)) 
		THEN
		   -- TRUE
		   SET CompanySeq = InData_CompanySeq;
		    
		ELSE
		   -- FALES
		   UPDATE IsCheck_TEMP AS A
		   SET  A.IsCheck = 9999
			   ,A.Result  = 'Update 경우 ChgMajorName은 빈값 또는 이미 존재하는 MajorName의 값을 입력할 수 없습니다.'
		   WHERE (InData_OperateFlag LIKE 'U') ;
		   -- 체크종료 구문--------------------------------------------------------------------------
		   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
		   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
		   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
		   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
		   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
		   LEAVE Error_Out; -- 프로시져 종료
		   -- ------------------------------------------------------------------------------------
		END IF;
    END IF;
    
    
    
	-- Save할 경우 InData_MajorName 데이터가 같은 _TCBaseMajor.MajorSeq 기준으로  _TCBaseMajor.MajorName과 중복될 경우 에러발생----------------------------------------------------------------------------    
	IF ((SELECT IFNULL(A.MajorSeq	, 1111)   AS MajorSeq 
				FROM _TCBaseMajor	 		  AS A 
				RIGHT OUTER JOIN (SELECT '')  AS ERR_CHECK_1  ON A.CompanySeq       =    InData_CompanySeq
															 AND A.MajorName    	=    InData_MajorName
															 AND (InData_OperateFlag LIKE 'S') 
		limit 1
	     ) = (SELECT 1111)) 
	THEN
	   -- TRUE
	   SET CompanySeq = InData_CompanySeq;
	    
	ELSE
	   -- FALES
	   UPDATE IsCheck_TEMP AS A
	   SET  A.IsCheck = 9999
		   ,A.Result  = '같은 MinorName의 값을 입력할 수 없습니다.'
	   WHERE (InData_OperateFlag LIKE 'S') ;
	   -- 체크종료 구문--------------------------------------------------------------------------
	   SET IsCheck		= (SELECT A.IsCheck FROM IsCheck_TEMP AS A);
	   SET Result		= (SELECT A.Result  FROM IsCheck_TEMP AS A);    
	   IF ((SELECT IsCheck) = (SELECT 1111)) THEN SET RETURN_OUT = IsCheck; -- IsCheck : '1111'일 경우 정상, '9999'일 경우 에러발생
	   ELSE SELECT Result AS Result; SET RETURN_OUT = IsCheck; END IF;-- 에러가 발생할 경우 메시지 출력
	   DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
	   LEAVE Error_Out; -- 프로시져 종료
	   -- ------------------------------------------------------------------------------------
	END IF;    
    
    
    
	DROP TEMPORARY TABLE IsCheck_TEMP; -- 임시테이블 삭제
END $$
DELIMITER ;