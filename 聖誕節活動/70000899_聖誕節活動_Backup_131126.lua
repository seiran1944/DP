--Auther : K.J. Aris
--Version : 13.10.25.10.42
--ScriptID : 70000899

--/? world 0 108 0 759 30 573
----------------------------------------------------------------------Christmas_Skills
--function Lua_70000899_ChristmasInit()
	--variable settings
	--lists
	local _lua_70000899_SnowManBuffIDs = { 30009048 , 30009049 , 30009050 , 30009051 , 30009052 };--怪物被擊中後  隨機變雪人的種類 
	local _lua_70000899_SnowManInvalidTargetOrgIDs = { [10011853] = "Sentry" , [10011854] = "Dispenser" , [10011856] = "Frozer" };--無法被凍結的目標(功能型雪人) --IDs on this list won't be frozen as a SnowMan.
	
	--10011840哥布林
	--10011841雪怪
	--10011843 巨人
	local _lua_70000899_MonsterDamage = { [10011840] = 1 , [10011841] = 5 , [10011843] = 10 };--攻擊強度表(抗寒護甲)
	local _lua_70000899_MonsterArmor = { [10011840] = 2 , [10011841] = 5 , [10011843] = 10 };--怪物護甲(抗寒護甲)

	--30009380拿禮物後的歌布林
	--30009381拿禮物後的雪怪
	local _lua_70000899_MonsterCustume ={ [10011840] = 30009380 , [10011841] = 30009381 };--怪物換裝表

	--basic magics
	local _lua_70000899_FrozeBuffID = 30009035;--30009035凍結
	local _lua_70000899_snowBallBuffID = 30009041;--雪球彈BUFF ID
	
	--玩家參數
	local _lua_70000899_playerSnowManBuffID = 30009405;--玩家變雪人的BUFF
	local _lua_70000899_playerDamage = 1;--玩家雪球攻擊強度--against_lua_70000899_snowBallBuffID 30009041
	local _lua_70000899_playerFrozenDropSnowNum = 10;--玩家被凍成雪人時掉的雪球量--_lua_70000899_snowBallBuffID 30009041	-- <0時直接取消
	local _lua_70000899_warmArmorMaxLV = 100;--抗寒護甲最高層數


	--聖誕怪
	local _lua_70000899_liveTimeAfterGetGift = 120;--(秒)怪物拿到禮物後消失的時間

	
	--功能型雪人
	local _lua_70000899_SnowManLiveTimerBuff = 30009275;--雪人存在倒數計時BUFF( 顯示用 )

	--魔雪人參數 
	local _lua_70000899_sentryAvatarID = 10011853;--10011853 魔雪人oriID

	local _lua_70000899_sentryLiveTime = 450;--魔雪人存在時間
	local _lua_70000899_sentryArmor = 30;--魔雪人護甲

	--雪雪人參數
	local _lua_70000899_dispenserAvatarID = 10011854;--10011854 雪雪人oriID

	local _lua_70000899_dispenserLiveTime = 450;--雪雪人存在時間
	local _lua_70000899_snowBallPeriod = 50;--雪球堆生成間隔 
	local _lua_70000899_dispenserArmor = 30;--雪雪人護甲

	--雪球堆參數
	local _lua_70000899_snowBallAvatarID = 10011855;--10011855 雪球堆oriID

	local _lua_70000899_snowBallLiveTime = 150;--雪球堆存在時間
	local _lua_70000899_snowBallsEachPack = 10;--每堆雪球的數量(每次取得數量)

	--冰凍雪人參數
	local _lua_70000899_frozerAvatarID = 10011856;--10011856 冰凍雪人oriID
	local _lua_70000899_frozerSpellID = 31010206;--31010206緩冰之計
	local _lua_70000899_frozerBuffID = 30008516;--30008516緩冰之計BUFF

	local _lua_70000899_frozerLiveTime = 450;--冰凍雪人存在時間
	local _lua_70000899_frozerActivePeriod = 10;--冰凍法術施展間隔
	local _lua_70000899_frozerArmor = 30;--冰凍雪人護甲

	--火堆參數
	local _lua_70000899_warmArmorBuffID = 30009240;--30009240抗寒護甲
	local _lua_70000899_warmArmorSkillID = 31010207;--31010207增加抗寒護甲

	local _lua_70000899_warmArmorActivePeriod = 20;--護甲回復施展間隔
--end
	

	------------------------------------------------------------------------------------------雪球
	function Lua_70000899_FrozeAsSnowMan()
		local _ownerID = OwnerID();
		local _targetID = TargetID();

		local _ownerIsPlayer = ReadRoleValue( _ownerID , EM_RoleValue_IsPlayer );
		local _targetIsPlayer = ReadRoleValue( _targetID , EM_RoleValue_IsPlayer );
		--30007735雪球擊中	--30009035凍結

		--檢查凍結無效
		local _freezeInvalidTarget = Lua_70000899_CheckSnowManInvalidTarget( _targetID );
		if ( _freezeInvalidTarget ) then--if = 凍結有效目標
			--for PC
			if ( _ownerIsPlayer == 0 and _targetIsPlayer == 1 ) then--當NPC擊中PC時
				local _hasArmor = CheckBuff( _targetID , _lua_70000899_warmArmorBuffID );
				if ( _hasArmor ) then--檢查玩家抗寒護甲

					local _damage = Lua_70000899_CheckDamageValue( _ownerID );

					Lua_ChangeBuffPower( _targetID , _targetID , _lua_70000899_warmArmorBuffID , -_damage );--減弱護甲
					AddBuff( _targetID , _ownerID , _lua_70000899_frozerBuffID , 1 , 20 );--30008516緩冰之計
					return;--有護甲不變雪人
				end

				--變雪人
				if ( not CheckBuff( _targetID , _lua_70000899_FrozeBuffID ) ) then--若已被凍結則不再凍
					local _snowManBuff = _lua_70000899_playerSnowManBuffID;--_lua_70000899_SnowManBuffIDs[ RandRange( 1 , #_lua_70000899_SnowManBuffIDs ) ];
					AddBuff( _targetID , _ownerID , _lua_70000899_FrozeBuffID , 1 , 30 );
					AddBuff( _targetID , _ownerID , _snowManBuff , 1 , 30 );--AddBuff( INT64 TargetID, INT64 CasterID, Int MagicBaseID, Int MagicLV, Int effectTime )
					--DebugMsg( 0 , "----".._ownerID.." => ".._snowManBuff );

					--掉雪球
					Lua_ChangeBuffPower( _targetID , _targetID , _lua_70000899_snowBallBuffID , -_lua_70000899_playerFrozenDropSnowNum );
				end
				
				  		
			end
			
			--for NPC
			if ( _ownerIsPlayer == 1 and _targetIsPlayer == 0 ) then--當PC擊中NPC時
				local _hasArmor = CheckBuff( _targetID , _lua_70000899_warmArmorBuffID );
				if ( _hasArmor ) then--檢查NPC抗寒護甲

					Lua_ChangeBuffPower( _targetID , _targetID , _lua_70000899_warmArmorBuffID , -_lua_70000899_playerDamage );--減弱護甲
					AddBuff( _targetID , _ownerID , _lua_70000899_frozerBuffID , 1 , 20 );--30008516緩冰之計
					ScriptMessage( _targetID , _ownerID , EM_ScriptMessageSendType_Target , EM_ClientMessage_Yabber ,  Lua_Event_Xmas_BubbleString() , 0 );
					return;--有護甲不死
				end
				--沒護甲去死
				KillID( _targetID , _ownerID );
			end

		else --if = 凍結無效目標
			--無效目標只扣護甲  不凍結
			local _hasArmor = CheckBuff( _targetID , _lua_70000899_warmArmorBuffID );
			if ( _hasArmor ) then--檢查NPC抗寒護甲
				local _damage = Lua_70000899_CheckDamageValue( _ownerID );
				Lua_ChangeBuffPower( _targetID , _targetID , _lua_70000899_warmArmorBuffID , -_damage );--減弱護甲
				return;--有護甲不死
			end
			--沒護甲去死
			KillID( _targetID , _ownerID );
		end

		return false;
	end
	
	function Lua_70000899_CheckDamageValue( _InputAttackerID )--查詢怪物傷害值
		local _ownerID = _InputAttackerID;
		local _attackerOrgID = ReadRoleValue( _ownerID , EM_RoleValue_OrgID );
		local _damage = _lua_70000899_MonsterDamage[ _attackerOrgID ];
		
		if ( not _damage ) then
			return 0;
		end
		
		return _damage;
	end
	
	function Lua_70000899_CheckSnowManInvalidTarget( _InputID )--檢查無效目標
		local _result = false;
		local _targetOrgID = ReadRoleValue( _InputID , EM_RoleValue_OrgID );
		local _targetType = _lua_70000899_SnowManInvalidTargetOrgIDs[ _targetOrgID ];
		
		if ( not _targetType ) and ( _isPlayer ~= 1 ) then
			_result = true;
		--else
			--DebugMsg( 0 , "Invalid Target : ".._targetOrgID.." -------- it's a ".._targetType );
		end

		return _result;
	end


	function Lua_70000899_CheckDamageInvalid()--30009042雪球傷害
		local _ownerID = OwnerID();
		local _targetID = TargetID();
		--檢查攻擊無效
		local _isPlayer = ReadRoleValue( _targetID , EM_RoleValue_IsPlayer );

		return ( _isPlayer == 0 );
	end
	----------------------------------------------------------------------------END-----------雪球

	--------------------------------------------------------------------------------------------火堆
	function Lua_70000899_OnlyWorksOnPlayer()--30009240抗寒護甲
		local _ownerID = OwnerID();
		local _targetID = TargetID();
		--檢查玩家
		local _isPlayer = ReadRoleValue( _targetID , EM_RoleValue_IsPlayer );

		return ( _isPlayer == 1 );
	end


	function Lua_70000899_AddWarmArmor()--NPC 10011961
		local _ownerID = OwnerID();
		local _targetID = TargetID();
		

		local _hasArmor = CheckBuff( _targetID , _lua_70000899_warmArmorBuffID );
		--DebugMsg( 0 , tostring( _hasArmor ) );
		if ( not _hasArmor ) then
			AddBuff( _targetID , _targetID , _lua_70000899_warmArmorBuffID , 0 , -1 );
			return false;
		end
		
		local _armorCounter = BuffInfo( _targetID , Lua_GetBuffPos( _targetID , _lua_70000899_warmArmorBuffID ) , EM_BuffInfoType_MagicLv ) + 1; 
		--DebugMsg( 0 , " BuffLV "..tostring( _armorCounter ).."   ".._lua_70000899_warmArmorMaxLV );
		if ( _armorCounter < _lua_70000899_warmArmorMaxLV ) then
			Lua_ChangeBuffPower( _targetID , _targetID , _lua_70000899_warmArmorBuffID , 1 );
		end 
		
		return false;
	end

	----------------------------------------------------------------------------END-------------火堆


	function Lua_70000899_CreateFunctionalSnowMan( _InputAvatarID )
		local _ownerID = OwnerID();
		local _roomID = ReadRoleValue( _ownerID , EM_RoleValue_RoomID );
		Lua_CreateObjByObjEX( _InputAvatarID , _ownerID , 0 , 15 , _roomID );--Int DataID, INT64 TargetObj, Int ang, Int dis, Int RoomID

		return false;
	end

	function Lua_70000899_CheckSnowBallStock( _InputRequire )--PC Skills
		local _ownerID = OwnerID();
		--local _lua_70000899_snowBallBuffID = 30009041;

		local _hasBalls = CheckBuff( _ownerID , _lua_70000899_snowBallBuffID );
		local _require = _InputRequire or 1;

		if ( not _hasBalls ) then
			ScriptMessage( _ownerID, _ownerID, EM_ScriptMessageSendType_Target, EM_ClientMessage_Warning , "Insufficient snowball !! go get some by the Dispenser !!" , 0 );
			return false;
		end
		
		local _snowBallCounter = BuffInfo( _ownerID , Lua_GetBuffPos( _ownerID , _lua_70000899_snowBallBuffID ) , EM_BuffInfoType_MagicLv ) + 1;
		local _sufficient = ( _snowBallCounter >= _require );

		if ( not _sufficient ) then
			ScriptMessage( _ownerID, _ownerID, EM_ScriptMessageSendType_Target, EM_ClientMessage_Warning , "Insufficient snowball !! go get some by the Dispenser !!" , 0 );
		end

		return _sufficient;
		--return true;
	end

	function Lua_70000899_ConsumeSnowBall( _InputConsume )--PC Skills
		local _ownerID = OwnerID();
		--local _lua_70000899_snowBallBuffID = 30009041;

		local _hasBalls = CheckBuff( _ownerID , _lua_70000899_snowBallBuffID );

		if ( _hasBalls ) then
			local _snowBallExpend = _InputConsume or 1;

			Lua_ChangeBuffPower( _ownerID , _ownerID , _lua_70000899_snowBallBuffID , -_snowBallExpend );

	--		local _snowBallCounter = 0;
	--		_snowBallCounter = BuffInfo( _ownerID , Lua_GetBuffPos( _ownerID , _lua_70000899_snowBallBuffID ) , EM_BuffInfoType_MagicLv );
	--		if ( _snowBallCounter <= 0 ) then
	--			CancelBuff( _ownerID , _lua_70000899_snowBallBuffID );
	--		end
		end--

	end

	function Lua_70000899_OnStartChristmasActivity( _InputOnwerID )--Lua_70000900_ActivityDrill
		local _ownerID = _InputOnwerID or OwnerID();
		--local _targetID = TargetID();
		DebugMsg( 0 , "Christmas Activity has started !!");
		Lua_70000899_SnowBallAcquisition( _ownerID );--給予雪球
		AddBuff( _ownerID , _ownerID , _lua_70000899_warmArmorBuffID , _lua_70000899_warmArmorMaxLV - 1 , -1 );--給予抗寒護甲
		
		return true;
	end


	--function Lua_70000899_OnEndChristmasActivity( _Type , _unknow )--Basic Magic 30009037
	function Lua_70000899_OnEndChristmasActivity()--Basic Magic 30009037
		local _ownerID = OwnerID();
		--local _lua_70000899_snowBallBuffID = 30009041;
		CancelBuff( _ownerID , _lua_70000899_snowBallBuffID );
		CancelBuff( _ownerID , _lua_70000899_warmArmorBuffID );

		--DebugMsg( 0 , "__".._Type.."____".._unknow );
	end
	--------------------------------------------------------------END-----Christmas_Skills


	----------------------------------------------------------------------Christmas_AIs
	function Lua_70000899_Christmas_AI_Init()
		local _ownerID = OwnerID();
		SetModeEx(  _ownerID  , EM_SetModeType_Fight, true); 
		SetModeEx(  _ownerID  , EM_SetModeType_Strikback, true); 
		SetModeEx(  _ownerID  , EM_SetModeType_Searchenemy, true );

		SetModeEx(  _ownerID  , EM_SetModeType_Mark, true); 
		WriteRoleValue( _ownerID , EM_RoleValue_Register + 1 , 0 );


		
		local _ownerOrgID = ReadRoleValue( _ownerID , EM_RoleValue_OrgID );
		local _armor = _lua_70000899_MonsterArmor[ _ownerOrgID ];
		
		if ( _armor ) then
			AddBuff( _ownerID , _ownerID , _lua_70000899_warmArmorBuffID , 0 , -1 );
		end

		Lua_ChangeBuffPower( _ownerID , _ownerID , _lua_70000899_warmArmorBuffID , _armor - 1 );

		local _isTheif =  ReadRoleValue( _ownerID , EM_RoleValue_Register ); 
		if ( _isTheif <= 0 ) then
			BeginPlot( _ownerID , "Lua_70000899_Christmas_AI_StealGift" , RandRange( 10 , 50 ) );
		end
	end--function Lua_70000899_Christmas_AI_StealGift

	function Lua_70000899_Christmas_AI_StealGift()--偷禮物
		local _ownerID = OwnerID();
		local _gotGift = ReadRoleValue( _ownerID , EM_RoleValue_Register + 1 ); 
		if ( _gotGift == 0 ) then
			BeginPlot( _ownerID , "Lua_70000899_Christmas_AI_ToPrimaryTarget" , 10 );
			--DebugMsg( 0 , "Stealing Gift : ".._ownerID );
		else	
			BeginPlot( _ownerID , "Lua_70000899_Christmas_AI_ReturnToHome" , 10 );
			--DebugMsg( 0 , "Returnung home : ".._ownerID );
		end
	end--function Lua_70000899_Christmas_AI_StealGift

	function Lua_70000899_Christmas_AI_TakeAndReturnToHome()--拿禮物後回家
		local _ownerID = OwnerID();
		local _targetID = TargetID();

		local _gotGift = ReadRoleValue( _targetID , EM_RoleValue_Register + 1 ); 
		if ( _gotGift == 0 ) then
			
			StopMove( _targetID , false );		
			
			local _randomPos = (RandRange( 0 , 100 ) % 4) + 1;
			WriteRoleValue( _ownerID , EM_RoleValue_Register + 1 , _randomPos );

			--WriteRoleValue( _targetID , EM_RoleValue_Register + 1 , 1 );
			--SetModeEx(  _targetID, EM_SetModeType_Strikback, false) ;---反擊
			SetModeEx(  _targetID, EM_SetModeType_Searchenemy, false) ;---索敵
				
			PlayMotionEX( _targetID , 34000702 , 34000702 , 0 );
				
			BeginPlot( _targetID , "Lua_70000899_Christmas_AI_ReturnToHome" , 20 );
		end
	
		return false;
	end--function Lua_70000899_Christmas_AI_TakeAndReturnToHome

	function Lua_70000899_Christmas_AI_ReturnToHome()--返回出生點
		local _ownerID = OwnerID();
		local _gotGift = ReadRoleValue( _ownerID , EM_RoleValue_Register + 1 );

		if ( _gotGift == 0 ) then
			local _randomPos = (RandRange( 0 , 100 ) % 4) + 1;
			WriteRoleValue( _ownerID , EM_RoleValue_Register + 1 , _randomPos );
			_gotGift = ReadRoleValue( _ownerID , EM_RoleValue_Register + 1 );
			WriteRoleValue( _ownerID , EM_RoleValue_LiveTime , _lua_70000899_liveTimeAfterGetGift );
			Lua_70000899_Christmas_AI_WearCustume( _ownerID );--換裝
			PE_AddVar("PE_EVT_Xmas_Gifts" , 1 );--寫積分 
		end

		SetModeEx(  _ownerID , EM_SetModeType_Searchenemy, false) ;---索敵
		--DebugMsg( 0 , " _ ".._ownerID.."Returning to ".._gotGift );	
		--Lua_MoveToFlag( _ownerID , _lua_70000900_Christmas_FlagID , _gotGift , 0 );
		Lua_WaitToMoveFlag( _ownerID , _lua_70000900_Christmas_FlagID , _gotGift , 0 );
		--PE_AddVar("PE_EVT_Xmas_Gifts" , 1 );--回到巢穴才寫積分 
		Sleep( 20 );
		DelObj( _ownerID );
		
		
	end--function Lua_70000899_Christmas_AI_ReturnToHome

	function Lua_70000899_Christmas_AI_ToPrimaryTarget()--前往目標
		local _ownerID = OwnerID();
		MoveToFlagEnabled( _ownerID, false );

		SetModeEx(  _ownerID  , EM_SetModeType_Fight, true); 
		SetModeEx(  _ownerID  , EM_SetModeType_Strikback, true); 
		SetModeEx(  _ownerID  , EM_SetModeType_Searchenemy, true );

		SetModeEx(  _ownerID  , EM_SetModeType_Mark, true); 
		WriteRoleValue( _ownerID , EM_RoleValue_Register + 1 , 0 );

		Lua_MoveToFlag( _ownerID , _lua_70000900_Christmas_FlagID , 0 , 0 );
		--Lua_WaitToMoveFlag( _ownerID , _lua_70000900_Christmas_FlagID , 0 , 0 );
		--BeginPlot( _ownerID , "Lua_70000899_Christmas_AI_ReturnToHome" , 20 );
	end

	function Lua_70000899_Christmas_AI_WearCustume( _InputOwnerID )--拿到禮物後變裝
		local _ownerID = _InputOwnerID;
		local _ownerOrgID = ReadRoleValue( _ownerID , EM_RoleValue_OrgID );
		local _custumeBuffID = _lua_70000899_MonsterCustume[ _ownerOrgID ];

		if ( not _custumeBuffID ) then
			return;
		end

		--DebugMsg( 0 , "Changing Custume : ".._ownerID.." -> ".._custumeBuffID );
		AddBuff( _ownerID , _ownerID , _custumeBuffID , 1 , -1 );--30008516緩冰之計
	end


	function Lua_70000899_Christmas_AI_Dead()
		local _ownerID = OwnerID();
		--30006871凍結
		local _snowManBuff = _lua_70000899_SnowManBuffIDs[ RandRange( 1 , #_lua_70000899_SnowManBuffIDs ) ];
		AddBuff( _ownerID , _ownerID , _snowManBuff , 1 , 20 );--AddBuff( INT64 TargetID, INT64 CasterID, Int MagicBaseID, Int MagicLV, Int effectTime )
		AddBuff( _ownerID , _ownerID , _lua_70000899_FrozeBuffID , 1 , 20 );--AddBuff( INT64 TargetID, INT64 CasterID, Int MagicBaseID, Int MagicLV, Int effectTime )
		
		SetModeEx(  _ownerID  , EM_SetModeType_Fight, false); 
		SetModeEx(  _ownerID  , EM_SetModeType_Strikback, false); 
		SetModeEx(  _ownerID  , EM_SetModeType_Searchenemy, false );

		SetModeEx(  _ownerID  , EM_SetModeType_Mark, false); 
		--SetModeEx(  _ownerID  , EM_SetModeType_HideName, true); 
		--SetModeEx(  _ownerID  , EM_SetModeType_ShowRoleHead, false); 
		--SetModeEx(  _ownerID  , EM_SetModeType_NotShowHPMP, false );

		--Sleep( 50 );
		
		--DelObj( _ownerID );
		DebugMsg( 0 , "----".._ownerID.."is Dead" );

		CallPlot( _ownerID , "Lua_Event_Xmas_GiftsTheftDead" );
		BeginPlot( _ownerID , "Lua_70000899_Christmas_AI_Delete" , 20 );
		return false;
	end--function Lua_70000899_Christmas_AI_Dead

	function Lua_70000899_Christmas_AI_Delete()
		--Sleep( 20 );
		NPCDead( OwnerID() , OwnerID() ); 
		DelObj( OwnerID() );
		--DebugMsg( 0 , tostring( DelObj( OwnerID() ) ) );
		--return true;
	end--function Lua_70000899_Christmas_AI_Delete

	---------------------------------------------------------------------END---------Christmas_AIs



	----------------------------------------------------------------------Christmas_Items

	---------------------------------------------------------------------------------------------------------------Sentry
	function Lua_70000899_Christmas_Item_Sentry_Init()--NPC 10011853
		local _ownerID = OwnerID();
		--local _liveTime = 450;
		local _liveTime = _lua_70000899_sentryLiveTime;

		WriteRoleValue( _ownerID , EM_RoleValue_LiveTime , _liveTime );
		
		SetModeEx( _ownerID , EM_SetModeType_Revive , false );--不重生
		SetModeEx(  _ownerID, EM_SetModeType_Move, false) ;---移動
		SetModeEx(  _ownerID, EM_SetModeType_Strikback, true) ;---反擊
		SetModeEx(  _ownerID, EM_SetModeType_Searchenemy, true) ;---索敵
		SetModeEx( _ownerID , EM_SetModeType_Fight, false) ;---可砍殺
		SetModeEx( _ownerID , EM_SetModeType_Obstruct, true) ;---可阻擋

		AddBuff( _ownerID , _ownerID , _lua_70000899_SnowManLiveTimerBuff , 0 , _liveTime*10 );
		AddBuff( _ownerID , _ownerID , _lua_70000899_warmArmorBuffID , _lua_70000899_sentryArmor - 1 , -1 );--給予抗寒護甲
	end
	-------------------------------------------------------------------------------------------END-----------------Sentry

	---------------------------------------------------------------------------------------------------------------Dispenser
	function Lua_70000899_Christmas_Item_Dispenser_Init()--NPC 10011854
		local _ownerID = OwnerID();
		--local _liveTime = 150;
		local _liveTime = _lua_70000899_dispenserLiveTime;

		WriteRoleValue( _ownerID , EM_RoleValue_LiveTime , _liveTime );
		
		SetModeEx( _ownerID , EM_SetModeType_Revive , false );--不重生
		SetModeEx(  _ownerID, EM_SetModeType_Move, false) ;---移動
		SetModeEx(  _ownerID, EM_SetModeType_Strikback, false) ;---反擊
		SetModeEx(  _ownerID, EM_SetModeType_Searchenemy, false) ;---索敵
		SetModeEx( _ownerID , EM_SetModeType_Fight, false) ;---可砍殺
		SetModeEx( _ownerID , EM_SetModeType_Obstruct, true) ;---可阻擋
		
		AddBuff( _ownerID , _ownerID , _lua_70000899_SnowManLiveTimerBuff , 0 , _liveTime*10 );
		AddBuff( _ownerID , _ownerID , _lua_70000899_warmArmorBuffID , _lua_70000899_dispenserArmor - 1 , -1 );--給予抗寒護甲
		--CastSpell( _ownerID , _ownerID , 31010103 , 1 );
		BeginPlot( _ownerID , "Lua_70000899_Christmas_Item_Dispenser_OnDuty" , 20 );
	end

	function Lua_70000899_Christmas_Item_Dispenser_OnDuty()
		
		local _ownerID = OwnerID();
		local _roomID = ReadRoleValue( _ownerID , EM_RoleValue_RoomID );

		--local _liveTime = 150;
		local _liveTime = _lua_70000899_snowBallLiveTime
		--local _lua_70000899_snowBallAvatarID = 10011855;--10011855 雪球堆	
		--local _lua_70000899_snowBallPeriod = 50;
		local _currentSnowBallID = 0;
		while true do
			_currentSnowBallID = Lua_CreateObjByObjEX( _lua_70000899_snowBallAvatarID , _ownerID , RandRange( 0 , 360 ) , RandRange( 10 , 20 ) , _roomID );--Int DataID, INT64 TargetObj, Int ang, Int dis, Int RoomID
			WriteRoleValue( _currentSnowBallID , EM_RoleValue_LiveTime , _liveTime );

			SetModeEx(  _currentSnowBallID, EM_SetModeType_Move, false) ;---移動
			SetModeEx(  _currentSnowBallID, EM_SetModeType_Strikback, false) ;---反擊
			SetModeEx(  _currentSnowBallID, EM_SetModeType_Searchenemy, false) ;---索敵
			SetModeEx( _currentSnowBallID , EM_SetModeType_Fight, false) ;---可砍殺
			SetModeEx( _currentSnowBallID , EM_SetModeType_Obstruct, false) ;---可阻擋	
		
			Sleep( _lua_70000899_snowBallPeriod );
		end

	end

--	function Lua_70000899_Christmas_Item_Dispenser_GenerateSnowBall()
--		local _ownerID = OwnerID();
--		local _roomID = ReadRoleValue( _ownerID , EM_RoleValue_RoomID );
--
--		--local _liveTime = 150;
--		local _liveTime = _lua_70000899_snowBallLiveTime;
--		--local _lua_70000899_snowBallAvatarID = 10011855;--10011855 雪球堆	
--		local _currentSnowBallID = 0;
--
--		_currentSnowBallID = Lua_CreateObjByObjEX( _lua_70000899_snowBallAvatarID , _ownerID , RandRange( 0 , 360 ) , RandRange( 10 , 20 ) , _roomID );--Int DataID, INT64 TargetObj, Int ang, Int dis, Int RoomID
--		WriteRoleValue( _currentSnowBallID , EM_RoleValue_LiveTime , _liveTime );
--
--		SetModeEx(  _currentSnowBallID, EM_SetModeType_Move, false) ;---移動
--		SetModeEx(  _currentSnowBallID, EM_SetModeType_Strikback, false) ;---反擊
--		SetModeEx(  _currentSnowBallID, EM_SetModeType_Searchenemy, false) ;---索敵
--		SetModeEx( _currentSnowBallID , EM_SetModeType_Fight, false) ;---可砍殺
--		SetModeEx( _currentSnowBallID , EM_SetModeType_Obstruct, false) ;---可阻擋	
--
--		--DebugMsg( 0 , "--------Dispenser ".._ownerID.." created 1 ball." );
--	end
	-------------------------------------------------------------------------------------------END-----------------Dispenser

	---------------------------------------------------------------------------------------------------------------SnowBall
	function Lua_70000899_Christmas_Item_SnowBallPickup()
		local _ownerID = OwnerID();--player
		local _targetID = TargetID();--snow balls

		DelObj( _targetID );
		Lua_70000899_SnowBallAcquisition( _ownerID );
	end

	function Lua_70000899_SnowBallAcquisition( _InputTargetID )
		local _ownerID = _InputTargetID or OwnerID();--player
		
		--local _lua_70000899_snowBallBuffID = 30009041;
		--local _lua_70000899_snowBallsEachPack = 10;--10 balls each pack
		local _snowBallsAcquiredAmmount = _lua_70000899_snowBallsEachPack;
		local _hasBalls = CheckBuff( _ownerID , _lua_70000899_snowBallBuffID );

		if ( not _hasBalls ) then
			AddBuff( _ownerID , _ownerID , _lua_70000899_snowBallBuffID , 0 , -1 );
			_snowBallsAcquiredAmmount =  _snowBallsAcquiredAmmount - 1;
		end

		Lua_ChangeBuffPower( _ownerID , _ownerID , _lua_70000899_snowBallBuffID , _snowBallsAcquiredAmmount );

	end
	-------------------------------------------------------------------------------------------------END-----------SnowBall

	---------------------------------------------------------------------------------------------------------------Frozer
	function Lua_70000899_Christmas_Item_Frozer_Init()--NPC 10011856
		local _ownerID = OwnerID();
		--local _liveTime = 150;
		local _liveTime = _lua_70000899_frozerLiveTime;

		WriteRoleValue( _ownerID , EM_RoleValue_LiveTime , _liveTime );
		
		SetModeEx( _ownerID , EM_SetModeType_Revive , false );--不重生
		SetModeEx(  _ownerID, EM_SetModeType_Move, false) ;---移動
		SetModeEx(  _ownerID, EM_SetModeType_Strikback, false) ;---反擊
		SetModeEx(  _ownerID, EM_SetModeType_Searchenemy, false) ;---索敵
		SetModeEx( _ownerID , EM_SetModeType_Fight, false) ;---可砍殺
		SetModeEx( _ownerID , EM_SetModeType_Obstruct, true) ;---可阻擋
		
		AddBuff( _ownerID , _ownerID , _lua_70000899_SnowManLiveTimerBuff , 0 , _liveTime*10 );
		AddBuff( _ownerID , _ownerID , _lua_70000899_warmArmorBuffID , _lua_70000899_frozerArmor - 1 , -1 );--給予抗寒護甲
		--CastSpell( _ownerID , _ownerID , 31010206 , 1 );--30008516
		BeginPlot( _ownerID , "Lua_70000899_Christmas_Item_Frozer_OnDuty" , 20 );
	end

	function Lua_70000899_Christmas_Item_Frozer_OnDuty()
		
		local _ownerID = OwnerID();

		while true do
			--DebugMsg( 0 , "-----Freeze" );
			CastSpell( _ownerID , _ownerID , _lua_70000899_frozerSpellID , 1 );--30008516
			sleep( _lua_70000899_frozerActivePeriod );
		end
	end
	------------------------------------------------------------------------------------------------END------------Frozer

	---------------------------------------------------------------------------------------------------------------Campfire
	function Lua_70000899_Christmas_Item_Campfire_Init()--NPC 10011961
		local _ownerID = OwnerID();
		local _liveTime = 950;
		--local _liveTime = _lua_70000899_frozerLiveTime;

		WriteRoleValue( _ownerID , EM_RoleValue_LiveTime , _liveTime );

		SetModeEx(  _ownerID, EM_SetModeType_Move, false) ;---移動
		SetModeEx(  _ownerID, EM_SetModeType_Strikback, false) ;---反擊
		SetModeEx(  _ownerID, EM_SetModeType_Searchenemy, false) ;---索敵
		SetModeEx( _ownerID , EM_SetModeType_Fight, false) ;---可砍殺ss
		SetModeEx( _ownerID , EM_SetModeType_Obstruct, true) ;---可阻擋
		

		BeginPlot( _ownerID , "Lua_70000899_Christmas_Item_Campfire_OnDuty" , 20 );
	end

	function Lua_70000899_Christmas_Item_Campfire_OnDuty()
		
		local _ownerID = OwnerID();

		while true do
			CastSpell( _ownerID , _ownerID , _lua_70000899_warmArmorSkillID , 1 );--31010207抗寒護甲
			sleep( _lua_70000899_warmArmorActivePeriod );
		end
	end
	-------------------------------------------------------------------------------------------END-----------------Campfire
	


	function Lua_70000899_Christmas_Item_GiftKeeper_Init()--NPC 10011838
		local _ownerID = OwnerID();
		--local _liveTime = 150;
		--local _liveTime = _lua_70000899_frozerLiveTime;
		DebugMsg( 0 , " GiftKeeper is on duty" );

		--WriteRoleValue( _ownerID , EM_RoleValue_LiveTime , _liveTime );

		SetModeEx(  _ownerID, EM_SetModeType_Move, false) ;---移動
		SetModeEx(  _ownerID, EM_SetModeType_Strikback, false) ;---反擊
		SetModeEx(  _ownerID, EM_SetModeType_Searchenemy, false) ;---索敵
		SetModeEx( _ownerID , EM_SetModeType_Fight, false) ;---可砍殺ss
		SetModeEx( _ownerID , EM_SetModeType_Obstruct, false) ;---可阻擋
		--SetModeEx( _ownerID , EM_SetModeType_Show , false );

		BeginPlot( _ownerID , "Lua_70000899_Christmas_Item_GiftKeeper_OnDuty" , 20 );
	end

	function Lua_70000899_Christmas_Item_GiftKeeper_OnDuty()
		
		local _ownerID = OwnerID();

		while true do
			CastSpell( _ownerID , _ownerID , 31010316 , 1 );--31010207抗寒護甲
			sleep( 5 );
		end
	end

	-------------------------------------------------------------END------Christmas_Items
	

	--return false;
--end--function Lua_70000899_ChristmasInit