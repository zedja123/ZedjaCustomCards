-- Milacresy Darkllunism Sacrifice
local s,id=GetID()
function s.initial_effect(c)
	-- Send 1 "Milacresy" monster from Deck to GY, or Special Summon it if no monsters are controlled
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
	-- Set this card if it is banished
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
end

-- Target to send 1 "Milacresy" monster to GY or Special Summon it
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	else
		e:SetCategory(CATEGORY_TOGRAVE)
	end
end

-- Send 1 "Milacresy" monster to GY or Special Summon it
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>=1
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		else
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

-- Filter for "Milacresy" monsters
function s.tgfilter(c)
	return c:IsSetCard(0xf16) and c:IsAbleToGrave()
end

-- Condition for setting the card when banished
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_REMOVE)
end

-- Target for setting the card
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end

-- Operation to set the card
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SSet(tp,e:GetHandler())
end
