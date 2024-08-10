-- Define the card
local s,id=GetID()
function s.initial_effect(c)
	-- Synchro Summon Procedure
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_TUNER),1,1,aux.FilterBoolFunctionEx(Card.IsType,TYPE_MONSTER),1,1)
	-- Cannot Pendulum Summon except "Lavoisier" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.pendlimit)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_FUSION_SUMMON)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.pendulum_target)
	e2:SetOperation(s.pendulum_operation)
	c:RegisterEffect(e2)

	-- Monster Effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.monster_target)
	e3:SetOperation(s.monster_operation)
	c:RegisterEffect(e3)

	-- Place in Pendulum Zone and additional Pendulum Summon effect
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.pzcon)
	e5:SetTarget(s.pztg)
	e5:SetOperation(s.pzop)
	c:RegisterEffect(e5)
end

-- Pendulum Effect: Restrict Pendulum Summons
function s.pendlimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xf13) and (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

-- Pendulum Effect: Fusion Summon
function s.pendulum_target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,0xf13),tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.pendulum_operation(e,tp,eg,ep,ev,re,r,rp)
	local fusion_card_id = 0x123 -- Replace with the ID of "Lavoisier Amazing Draco - YOUCAN"
	local mat_filter = function(c) return c:IsSetCard(0xf13) and (c:IsLocation(LOCATION_EXTRA) or c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_ONFIELD)) end
	
	if not e:GetHandler():IsRelateToEffect(e) then return end
	
	-- Select Fusion Material
	local materials = Duel.GetMatchingGroup(mat_filter,tp,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_ONFIELD,0,nil)
	if #materials == 0 then return end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local g = Duel.SelectMatchingCard(tp,mat_filter,tp,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_ONFIELD,0,1,99,nil)
	if #g == 0 then return end
	
	-- Shuffle materials into Deck
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	
	-- Fusion Summon
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local fusion_card = Duel.CreateToken(tp,fusion_card_id)
	Duel.SpecialSummon(fusion_card,0,tp,tp,false,false,POS_FACEUP)
end


-- Monster Effect: Add "Lavoisier" monsters to hand
function s.monster_target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,2,nil,0xf13) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_EXTRA)
end
function s.extrafaceup(c)
	return c:IsSetCard(0xf13) and c:IsFaceup()
end
function s.monster_operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
			if Duel.IsExistingMatchingCard(s.extrafaceup,tp,LOCATION_EXTRA,0,1,nil) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local hg=Duel.SelectMatchingCard(tp,s.extrafaceup,tp,LOCATION_EXTRA,0,1,2,nil)
				if #hg>0 then
					Duel.SendtoHand(hg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,hg)
				end
			end
		end
	end
end

function s.pzcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end

function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
		-- Allow an additional Pendulum Summon
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_EXTRA,0)
		e1:SetRange(LOCATION_PZONE)
		e1:SetCondition(s.pscon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.pscon(e)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)==0
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end

function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

-- Activate effect to move the card to Pendulum Zone
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
		-- You can conduct 1 Pendulum Summon of a monster(s) in addition to your Pendulum Summon this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_EXTRA,0)
		e1:SetRange(LOCATION_PZONE)
		e1:SetCondition(s.condition)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	end
end