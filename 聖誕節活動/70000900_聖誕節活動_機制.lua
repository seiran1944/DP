--Auther : K.J. Aris
--Version : 13.10.25.10.42
--ScriptID : 70000900

--NPC
	--10011841雪怪
	--10011840哥布林
-------------------------------------------------------------------------------測試用
--/? world 0 108 0 759 30 573



function Lua_70000900_ChristmasTest()
	local _ownerID = OwnerID();
	local _roomID = ReadRoleValue( _ownerID , EM_RoleValue_RoomID );
	local _npcAvatarID = 0;

	local _RatioSeed = 0;
	
	local _npcID = 0;

	--DebugMsg( 0 , "----Lua_70000900_ChristmasTest" );
	local _addSucceed = false;
	for i = 1 , 33 , 1 do
		_RatioSeed = RandRange( 1 , 10 );
		if _RatioSeed <= 9 then
			_npcAvatarID = 10011840;--10011840哥布林
		else
			_npcAvatarID = 10011841;--10011841雪怪
		end
		_npcID = CreateObjByFlag( _npcAvatarID , _lua_70000899_Christmas_SpawnFlagID , i );
		WriteRoleValue( _npcID , EM_RoleValue_LiveTime , 30 );
		_addSucceed = AddToPartition( _npcID , _roomID );
		--DebugMsg( 0 , "---- ".._npcID.."  R: ".. _lua_70000899_Christmas_SpawnFlagID.." Q : " ..i.." : "..tostring( _addSucceed ) );
	end

	for i = 34 , 51 , 1 do
		_npcID = CreateObjByFlag( 10011853 , _lua_70000899_Christmas_SpawnFlagID , i );
		--WriteRoleValue( _npcID , EM_RoleValue_LiveTime , 30 );
		_addSucceed = AddToPartition( _npcID , _roomID );
	end

end--function Lua_70000900_ChristmasTest()


function Lua_70000900_ActivityDrill()
	local _ownerID = OwnerID();
	local _christmasBuffID = 30009037;

	--Lua_CancelAllBuff( _ownerID );--取消BUFF

	if ( CheckBuff( _ownerID , _christmasBuffID ) == true ) then
		CancelBuff( _ownerID , _christmasBuffID );
	else
		AddBuff( _ownerID , _ownerID , _christmasBuffID , 1 , -1 );
		Lua_70000899_OnStartChristmasActivity( _ownerID );
		--Lua_70000899_StartChristmasActivity( _ownerID );
		--Lua_70000899_SnowBallAcquisition( _ownerID );
	end
	
end--function Lua_70000900_ActivityDrill





function Lua_70000900_Christmas_StartWave()
	local _ownerID = OwnerID();

	CallPlot( _ownerID , "Lua_70000900_SeriesWave" , _ownerID );

end--function Lua_70000900_ChristmasTest()

function Lua_70000900_SeriesWave( _InputID )
	local _ownerID = _InputID;
	local _maxWave = 6;
	local _wavePeriod = 30;

--	local _npcID = CreateObjByFlag( 10011838 , _lua_70000899_Christmas_SpawnFlagID , 0 );
--	SetModeEx( _npcID , EM_SetModeType_Revive , false );--不重生
--	SetModeEx(  _npcID, EM_SetModeType_Move, false) ;---移動
--	SetModeEx(  _npcID, EM_SetModeType_Strikback, false) ;---反擊
--	SetModeEx(  _npcID, EM_SetModeType_Searchenemy, false) ;---索敵
--	SetModeEx( _npcID , EM_SetModeType_Fight, false) ;---可砍殺
--	SetModeEx( _npcID , EM_SetModeType_Obstruct, false) ;---可阻擋
--	--SetModeEx( _npcID , EM_SetModeType_HideName, true) ;--
--	--SetModeEx( _npcID , EM_SetModeType_Mark, false) ;--	


	for i = 1 , _maxWave , 1 do
		--BeginPlot( _ownerID , "Lua_70000900_Christmas_CreateMob" , _wavePeriod );
		Sleep( _wavePeriod );
		Lua_70000900_Christmas_CreateMob( _ownerID );
		_wavePeriod = _wavePeriod + RandRange( 50 , 10 );
		
	end

	

end


function Lua_70000900_Christmas_CreateMob( _InputOwnerID , _InputFlagPos )--隨機 在FLAG 0 ~ 3 產生怪物群
	local _ownerID = _InputOwnerID or OwnerID();
	local _roomID = ReadRoleValue( _ownerID , EM_RoleValue_RoomID );
	local _flagPos = _InputFlagPos or ( (RandRange( 0 , 100 ) % 4) );

	local _npcAvatarID = 0;

	local _RatioSeed = 0;
	
	local _npcID = 0;

	local _mobMaxNum = 12;--max numbers of the mob

	for i = 1 , _mobMaxNum , 1 do
		_RatioSeed = RandRange( 1 , 100 )%10;
		if _RatioSeed == 0 then
			_npcAvatarID = 10011841;--10011841雪怪
		else
			_npcAvatarID = 10011840;--10011840哥布林
		end
		_npcID = CreateObjByFlag( _npcAvatarID , _lua_70000899_Christmas_SpawnFlagID , _flagPos );
		WriteRoleValue( _npcID , EM_RoleValue_LiveTime , 180 );
		_addSucceed = AddToPartition( _npcID , _roomID );
		--DebugMsg( 0 , "---- ".._npcID.."  R: ".. _lua_70000899_Christmas_SpawnFlagID.." Q : " ..i.." : "..tostring( _addSucceed ) );
	end

end--function Lua_70000900_Christmas_CreateMob




-----------------------------------------------------------------END-----------測試用





function Lua_70000900_InitChristmasActivity()--PE 17000188
	--活動初始流程
	--Lua_70000899_ChristmasInit();--起始參數與函式

end