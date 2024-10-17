--Milacresy Extrallunism - Bibi-bee
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon this card if sent to the GY or banished by "Milacresy" card effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re) return e:GetHandler():IsReason(REASON_EFFECT) and re:GetHandler():IsSetCard(0xf16) end)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetCountLimit(1, {id, 1})
	c:RegisterEffect(e1)

	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)

	-- Add a "Milacresy" Spell/Trap when Special Summoned
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1, {id, 2})
	e3:SetTarget(s.addtg)
	e3:SetOperation(s.addop)
	c:RegisterEffect(e3)
end

function s.shfilter(c)
	return c:IsSetCard(0xf16) and c:IsAbleToDeckOrExtraAsCost() and not c:IsCode(id)
end

-- Cost: Shuffle 3 "Milacresy" cards from your GY or banished
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.shfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,c) end
	local g=Duel.SelectMatchingCard(tp,s.shfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,c)
	Duel.HintSelection(g)
	Duel.SendtoDeck(g,nil,3,REASON_COST)
end

-- Target: This card from GY or banished
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

-- Operation: Special Summon this card
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP)
end
function s.addfilter(c)
	return c:IsSetCard(0xf16) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
end
-- Target: Add a "Milacresy" Spell/Trap from Deck to hand
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 0, tp, 1)
end

-- Operation: Add the selected Spell/Trap to hand
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
