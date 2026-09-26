--
--Rank-Up-Magic - Chaos Puppet Form
--scripted by Zedja
local s,id=GetID()
function s.initial_effect(c)
	--During the Main Phase: Special Summon 1 "Gimmick Puppet" Xyz Monster from your Extra Deck or GY, then Special Summon from your Extra Deck, 1 "Number C" or "CXyz" monster that is 1 Rank higher than that monster, by using it as material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--You can banish this card from your GY; look at your opponent's Deck and Extra Deck, and Special Summon 1 monster from among them to either player's field, ignoring its Summoning conditions
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GIMMICK_PUPPET,SET_NUMBER_C,SET_CXYZ}
function s.filter1(c,e,tp)
	if not (c:IsSetCard(SET_GIMMICK_PUPPET) and c:IsType(TYPE_XYZ) and (c:GetRank()>0 or c:IsStatus(STATUS_NO_LEVEL))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		if Duel.GetLocationCountFromEx(tp,tp,nil,c)<=0 then return false end
	elseif Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then
		return false
	end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(c),tp,nil,nil,REASON_XYZ)
	return (#pg<=0 or (#pg==1 and pg:IsContains(c)))
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,c,e,tp,c,c:GetRank()+1)
end
function s.filter2(c,e,tp,mc,rk)
	if c.rum_limit and not c.rum_limit(mc,e) then return false end
	return c:IsType(TYPE_XYZ) and c:IsRank(rk) and c:IsSetCard({SET_NUMBER_C,SET_CXYZ})
		and mc:IsType(TYPE_XYZ,c,SUMMON_TYPE_XYZ,tp) and mc:IsCanBeXyzMaterial(c,tp)
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0 and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter1),tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if not tc or Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local pg=aux.GetMustBeMaterialGroup(tp,Group.FromCards(tc),tp,nil,nil,REASON_XYZ)
	if #pg>1 or (#pg==1 and not pg:IsContains(tc)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1):GetFirst()
	if sc then
		Duel.BreakEffect()
		sc:SetMaterial(Group.FromCards(tc))
		Duel.Overlay(sc,tc)
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
function s.fieldcheck(c,e,tp,p)
	if not c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP,p) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(p,tp,nil,c)>0
	end
	return Duel.GetLocationCount(p,LOCATION_MZONE,tp)>0
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and (s.fieldcheck(c,e,tp,tp) or s.fieldcheck(c,e,tp,1-tp))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_DECK|LOCATION_EXTRA,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_DECK|LOCATION_EXTRA)
	if #g==0 then return end
	Duel.ConfirmCards(tp,g)
	local sg=g:Filter(s.spfilter,nil,e,tp)
	if #sg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		local b1=s.fieldcheck(tc,e,tp,tp)
		local b2=s.fieldcheck(tc,e,tp,1-tp)
		local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,2)},{b2,aux.Stringid(id,3)})
		local p=op==1 and tp or 1-tp
		Duel.SpecialSummon(tc,0,tp,p,true,false,POS_FACEUP)
	end
	Duel.ShuffleDeck(1-tp)
	Duel.ShuffleExtra(1-tp)
end
