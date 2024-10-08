--Prismiant Destroyer
local s, id, o = GetID()
function c270000008.initial_effect(c)
	-- Special Summon itself if you control only "Prismiant" monsters
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetCountLimit(1, {id, 1})
	c:RegisterEffect(e1)

	-- Special Summon 1 "Prismiant" monster from your GY and discard 1 card from your hand
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	e1:SetCountLimit(1, {id, 2})
	c:RegisterEffect(e2)
	local e3 = e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		and not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.spfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0xf10)
end

function s.spfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf10)
end

function s.gytg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
		and Duel.IsExistingMatchingCard(s.spfilter2, tp, LOCATION_GRAVE, 0, 1, nil, e, tp)
		and Duel.IsExistingMatchingCard(Card.IsDiscardable, tp, LOCATION_HAND, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE)
	Duel.SetOperationInfo(0, CATEGORY_HANDES, nil, 0, tp, 1)
end

function s.gyop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, s.spfilter2, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp)
	if g:GetCount() > 0 and Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP) ~= 0 then
		Duel.BreakEffect()
		Duel.DiscardHand(tp, Card.IsDiscardable, 1, 1, REASON_EFFECT + REASON_DISCARD)
	end
end