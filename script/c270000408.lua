--Build Driver - Sky Wall
local s,id,o=GetID()
function s.initial_effect(c)
	-- Activate: Add 1 "Build Rider" monster from Deck to hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,1})
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	--Atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.con)
	e2:SetValue(200)
	c:RegisterEffect(e2)

	-- End Phase: Set 1 "Build Driver" card from GY or banished to your field
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end

-- e1: Add 1 "Build Rider" monster from Deck to hand
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.thfilter(c)
	return c:IsSetCard(0xf15) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

-- e2: "Build Rider" monsters gain 500 ATK during Battle Phase
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer() == tp and Duel.GetCurrentPhase() == PHASE_BATTLE
end

-- e3: Set 1 "Build Driver" card from GY or banished to your field during End Phase
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
function s.setfilter(c)
	return c:IsSetCard(0xf15) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
