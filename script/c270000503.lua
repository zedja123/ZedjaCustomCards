--Milacresy Extrallunism - Bibi-bee
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon this card if sent to the GY or banished by "Milacresy" card effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_TO_GRAVE+EVENT_REMOVE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re) return e:GetHandler():IsReason(REASON_EFFECT) and re and re:GetHandler():IsSetCard(0xf16) end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetCountLimit(1, {id, 1})
	c:RegisterEffect(e1)

	-- Add a "Milacresy" Spell/Trap when Special Summoned
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1, {id, 2})
	e2:SetTarget(s.addtg)
	e2:SetOperation(s.addop)
	c:RegisterEffect(e2)
end


function s.shfilter(c)
	return c:IsSetCard(0xf16)
end

-- Target: Shuffle 3 "Milacresy" cards from banished or GY
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	Debug.Message(Entrou TG)
	if chk==0 then return Duel.IsExistingMatchingCard(s.shfilter, tp, LOCATION_GRAVE+LOCATION_REMOVED, 0, 3, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 0, tp, 3)
end

-- Operation: Shuffle and Special Summon this card
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.shfilter, tp, LOCATION_GRAVE+LOCATION_REMOVED, 0, nil)
	if #g>0 and Duel.SendtoDeck(g,nil,2,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
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
