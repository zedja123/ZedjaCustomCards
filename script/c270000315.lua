-- Define the card
local s,id=GetID()
function s.initial_effect(c)
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

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.pendulum_cost)
	e4:SetTarget(s.pendulum_target)
	e4:SetOperation(s.pendulum_operation)
	c:RegisterEffect(e4)
end

-- Pendulum Effect: Restrict Pendulum Summons
function s.pendlimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xf13) and (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end

-- Pendulum Effect: Fusion Summon
function s.pendulum_target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0xf13),tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.pendulum_operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(Card.IsSetCard,0xf13),tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local mat=Duel.SelectFusionMaterial(tp,tc)
		Duel.FusionSummon(tp,tc,mat)
	end
end

-- Monster Effect: Add "Lavoisier" monsters to hand
function s.monster_target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,2,nil,0xf13) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_EXTRA)
end

function s.monster_operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(nil,tp,LOCATION_CONTROL,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_CONTROL,0,1,1,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
			if Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_EXTRA,0,2,nil,0xf13) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local hg=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_EXTRA,0,2,2,nil,0xf13)
				if #hg>0 then
					Duel.SendtoHand(hg,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,hg)
				end
			end
		end
	end
end

-- Cost for placing the card in the Pendulum Zone
function s.pendulum_cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanPlaceInPendulumZone(tp) end
	-- Place the card in the Pendulum Zone as a cost
	Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end

-- Target for additional Pendulum Summon
function s.pendulum_target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,0,tp,LOCATION_MZONE)
end

-- Operation for additional Pendulum Summon
function s.pendulum_operation(e,tp,eg,ep,ev,re,r,rp)
	-- Additional Pendulum Summon during Main Phase
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_MAIN1)
	Duel.RegisterEffect(e1,tp)
end