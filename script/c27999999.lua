local s,id,o=GetID()

function s.initial_effect(c)
	aux.AddPreDrawSkillProcedure(c, 1, false, s.startcon, s.startop)
end

function s.deck_check(tp)
	return Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_DECK,0,nil)>=6
end

function s.filter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:GetAttack()==2900
end

function s.startcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount() <= 2 and Duel.GetTurnPlayer() == tp and s.deck_check(tp)
end

function s.startop(e,tp,eg,ep,ev,re,r,rp)
	Debug.Message("startop entered")
	Duel.RegisterFlagEffect(tp,id+5,0,0,1)
	Debug.Message("Skill Zone Location: "..tostring(e:GetHandler():GetLocation()))
	Debug.Message("Flipping Skill Card: "..id)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	-- Effect Button Activations
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.buttoncon)
	e1:SetOperation(s.buttonop)
	Duel.RegisterEffect(e1, tp)
	if Duel.GetFlagEffect(tp,id+6)==0 then
		Duel.RegisterFlagEffect(tp,id+6,0,0,1)

		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SUMMON_PROC)
		e1:SetTargetRange(LOCATION_HAND,0)
		e1:SetCondition(s.ntcon)
		e1:SetDescription(aux.Stringid(id,5))
		Duel.RegisterEffect(e1,tp)

		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_PROC)
		e2:SetDescription(aux.Stringid(id,6))
		Duel.RegisterEffect(e2,tp)
	end

	if Duel.GetTurnCount()==2 and Duel.GetTurnPlayer()==tp and Duel.GetFlagEffect(tp,id+4)==0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then

		Duel.DisableShuffleCheck()
		local token=Duel.CreateToken(tp,99000151)
		if token then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EVENT_SPSUMMON_SUCCESS)
			e1:SetOperation(function () Duel.SetChainLimitTillChainEnd(aux.FALSE) end)
			token:RegisterEffect(e1)
			Duel.MoveToField(token,tp,tp,LOCATION_MZONE,POS_FACEDOWN_DEFENSE,true)
			Duel.RaiseEvent(token,EVENT_MSET,e,REASON_EFFECT,tp,tp,0)
			e1:Reset()
		end

		Duel.RegisterFlagEffect(tp,id+4,0,0,1)
	end

	Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
end

function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsRace(RACE_SPELLCASTER)
		and c:IsAttribute(ATTRIBUTE_DARK)
		and c:GetAttack()==2900
		and c:IsLevelAbove(5)
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end

function s.buttoncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if tp~=c:GetOwner() then return false end
	if Duel.GetFlagEffect(tp,id+5)==0 then return false end
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and aux.CanActivateSkill(tp)
		and (
			(Duel.GetFlagEffect(tp,id+2)==0 
				and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,48421595) 
				and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0)
			or aux.CanActivateSkill(tp) and
			(Duel.GetFlagEffect(tp,id+3)==0 
				and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,36405256)
				and Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_MZONE,0,nil)>0)
		)
end

function s.buttonop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local options = {}
	local ops = {}

	if Duel.GetFlagEffect(tp,id+2)==0 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,48421595) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0  then
		table.insert(options,aux.Stringid(id,1))
		table.insert(ops,2)
	end
	if Duel.GetFlagEffect(tp,id+3)==0 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,36405256) and Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_MZONE,0,nil)>0 then
		table.insert(options,aux.Stringid(id,2))
		table.insert(ops,3)
	end
	if #options==0 then return end

	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local sel=Duel.SelectOption(tp,table.unpack(options))
	local choice=ops[sel+1]

	if choice==2 then
		s.effect2(tp,e)
	elseif choice==3 then
		s.effect3(tp,e)
	end
end

function s.effect2(tp,e)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 then return end

	Duel.RegisterFlagEffect(tp,id+2,0,0,1)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if #g==0 then return end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)

	Duel.DisableShuffleCheck()
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK,0,1,1,nil,48421595)
	if #g>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetOperation(function () Duel.SetChainLimitTillChainEnd(aux.FALSE) end)
		g:GetFirst():RegisterEffect(e1)
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		e1:Reset()
	end

	local fg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if #fg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local sc=fg:Select(tp,1,1,nil):GetFirst()
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
		local lv=Duel.AnnounceNumber(tp,1,2)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sc:RegisterEffect(e1)
	end
end

function s.effect3(tp,e)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_MZONE,0,nil)==0 then return end

	Duel.RegisterFlagEffect(tp,id+3,0,0,1)

	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,LOCATION_MZONE,0,1,1,nil)
	if #g==0 then return end
	Duel.SendtoGrave(g,REASON_EFFECT)

	Duel.DisableShuffleCheck()
	local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK,0,1,1,nil,36405256)
	if #g>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetOperation(function () Duel.SetChainLimitTillChainEnd(aux.FALSE) end)
		g:GetFirst():RegisterEffect(e1)
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_MZONE,POS_FACEDOWN_DEFENSE,true)
		Duel.RaiseEvent(g:GetFirst(),EVENT_MSET,e,REASON_EFFECT,tp,tp,0)
		e1:Reset()
	end
end
