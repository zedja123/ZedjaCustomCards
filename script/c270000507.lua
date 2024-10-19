-- Milacresy Darkllunism Sacrifice
local s,id=GetID()
function s.initial_effect(c)
	-- Send 1 "Milacresy" monster from Deck to GY, or Special Summon it if no monsters are controlled
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
	-- Set from banished
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCountLimit(1,{id,2})
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

function s.negconfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf16)
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
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and g:GetFirst():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
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

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:IsFaceup() then
		Duel.SSet(tp,c)
	end
end