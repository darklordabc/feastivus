MusicPlayer = class({})

FeastivusMusicState = {}
FeastivusMusicState.Normal = 1 -- 1
FeastivusMusicState.RoundStart = 2 -- 1
FeastivusMusicState.RoundEnd = 3

function MusicPlayer:SetMusicState(musicState, bForceStart)
	if (self.musicState == musicState) and not bForceStart then
		return
	end
	
	self.musicState = musicState

	local musicName
	if musicState == FeastivusMusicState.Normal then
		musicName = table.random({
			"normal",
		})
	end
	if musicState == FeastivusMusicState.RoundStart then
		musicName = "round_start"
	end
	if musicState == FeastivusMusicState.RoundEnd then
		musicName = "round_end"
	end
	print("music player begin to play music" , musicName)
	local musicPlayer = GameRules:GetGameModeEntity()
	if self.pszCurrentTrack ~= nil then 
		musicPlayer:StopSound("FeastivusMusic." .. self.pszCurrentTrack)
	end
	if musicName ~= nil then
		-- 直接开始播放音乐
		-- 播放完成之后，递归播放
		musicPlayer:EmitSound("FeastivusMusic." .. musicName)
		self.pszCurrentTrack = musicName
	end
	
	musicPlayer:SetContextThink(DoUniqueString("small_delay"),function()
		local duration = 0
		if musicName ~= nil then
			duration = musicPlayer:GetSoundDuration("FeastivusMusic." .. musicName,nil) or 0
		end
		musicPlayer:SetContextThink(DoUniqueString(""),function()
			if musicState == FeastivusMusicState.RoundStart then
				musicState = FeastivusMusicState.Normal
			end

			-- @todo other special music status

			print(self.pszCurrentTrack, musicName)
			if self.pszCurrentTrack == musicName then
				self:SetMusicState(musicState, true)
			end
		end,duration)
	end,1)
end

GameRules.MusicPlayer = MusicPlayer()