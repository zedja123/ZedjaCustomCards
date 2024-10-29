--Build Driver - All Right!
local s,id,o=GetID()
function s.initial_effect(c)
	-- Tribute 1 "Build Rider" monster, Special Summon from Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,1})
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	
	-- GY effect: Shuffle banished/GY monster into Deck, Special Summon from Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,2})
	e2:SetCondition(s.gycon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end

-- e1: Tribute 1 "Build Rider" monster, Special Summon from Extra Deck
function s.spfilter1(c,e,tp)
	return c:IsSetCard(0xf15)
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp)
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0xf15) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,c)>0
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.spfilter1,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.SelectReleaseGroup(tp,s.spfilter1,1,1,nil,e,tp)
	if #rg>0 and Duel.Release(rg,REASON_EFFECT)~=0 then
		local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

-- e2: Shuffle banished/GY monster into Deck, Special Summon from Extra Deck
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()~=e:GetHandler():GetTurnID()
end
function s.extrafilter(c,e,tp)
	return c:IsSetCard(0xf15) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_LINK)
end
function s.tdfilter(c)
	return c:IsSetCard(0xf15) and c:IsAbleToDeck() and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
			and Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_LINK)>0
			and Duel.IsExistingMatchingCard(s.extrafilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local spg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.extrafilter),tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #spg>0 then
			Duel.SpecialSummon(spg,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)
			spg:GetFirst():CompleteProcedure()
		end
	end
end