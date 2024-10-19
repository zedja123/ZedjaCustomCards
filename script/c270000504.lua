--Milacresy Invallunism - Amarae
local s,id=GetID()
function c270000504.initial_effect(c)
	-- When Normal or Special Summoned
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))
e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e1:SetCode(EVENT_SUMMON_SUCCESS)
e1:SetProperty(EFFECT_FLAG_DELAY)
e1:SetCountLimit(1,{id,1})
e1:SetTarget(s.target)
e1:SetOperation(s.operation)
c:RegisterEffect(e1)
local e2=e1:Clone()
e2:SetCode(EVENT_SPSUMMON_SUCCESS)
c:RegisterEffect(e2)
end

-- Banish top 3 cards and Special Summon
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.spfilter(c,e,tp)
	return c:IsSetCard(0xf16) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	local g=Duel.GetDecktopGroup(tp,3)
	Duel.DisableShuffleCheck()
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end