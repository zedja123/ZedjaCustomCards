--Milacresy Extrallunism - Bibi-bee
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon this card if sent to the GY or banished by "Milacresy" card effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)

	-- Add a "Milacresy" Spell/Trap when Special Summoned
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.addtg)
	e2:SetOperation(s.addop)
	c:RegisterEffect(e2)
end

-- Condition: Check if sent to GY by a "Milacresy" card effect
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsSetCard(0xf16) and (e:GetHandler():IsPreviousLocation(LOCATION_HAND) or e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) or e:GetHandler():IsPreviousLocation(LOCATION_DECK))
end

-- Target: Shuffle 3 "Milacresy" cards from banished or GY
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard, tp, LOCATION_GRAVE+LOCATION_REMOVED, 0, 3, nil, 0xf16) end
	Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 0, tp, 3)
end

-- Operation: Shuffle and Special Summon this card
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSetCard, tp, LOCATION_GRAVE+LOCATION_REMOVED, 0, nil, 0xf16)
	if #g>0 and Duel.SendtoDeck(g,nil,2,REASON_EFFECT)~=0 then
		Duel.BreakEffect()
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end

-- Target: Add a "Milacresy" Spell/Trap from Deck to hand
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0xf16) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 0, tp, 1)
end

-- Operation: Add the selected Spell/Trap to hand
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,0xf16)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
