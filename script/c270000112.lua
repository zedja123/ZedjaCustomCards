--
--Wiccanthrope Stormgnarl
--scripted by Zedja
local s,id=GetID()
local SET_WICCANTHROPE=0xe01
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 5 monsters, or 1 Rank 4 or lower "Wiccanthrope" Xyz Monster you control
	Xyz.AddProcedure(c,nil,5,2,s.ovfilter,aux.Stringid(id,0))
	--Monsters your opponent controls lose 300 ATK/DEF for each face-up banished Spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--(Quick Effect): You can detach 1 material from this card; Special Summon 1 of your banished "Wiccanthrope" monsters, but shuffle it into the Deck when it leaves the field, also you can banish 1 Spell from your hand, field, or GY, and if you do, attach 1 Spell from your Deck to 1 Xyz Monster you control as material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e3:SetCountLimit(1,id)
	e3:SetCost(Cost.DetachFromSelf(1))
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_WICCANTHROPE}
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp) and c:IsRankBelow(4) and c:IsSetCard(SET_WICCANTHROPE,lc,SUMMON_TYPE_XYZ,tp)
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSpell),0,LOCATION_REMOVED,LOCATION_REMOVED,nil)*-300
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_WICCANTHROPE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.rmfilter(c)
	return c:IsSpell() and c:IsAbleToRemove()
end
function s.xyzfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.matfilter,tp,LOCATION_DECK,0,1,nil,c,tp)
end
function s.matfilter(c,xc,tp)
	return c:IsSpell() and c:IsCanBeXyzMaterial(xc,tp,REASON_EFFECT)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
			--Shuffle it into the Deck when it leaves the field
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3301)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetValue(LOCATION_DECKSHF)
			e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
			tc:RegisterEffect(e1,true)
		end
	end
	--Also you can banish 1 Spell from your hand, field, or GY, and if you do, attach 1 Spell from your Deck to 1 Xyz Monster you control as material
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,1,1,nil)
		if #rg==0 or Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local xc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
		if not xc then return end
		Duel.HintSelection(xc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local mg=Duel.SelectMatchingCard(tp,s.matfilter,tp,LOCATION_DECK,0,1,1,nil,xc,tp)
		if #mg>0 then
			Duel.Overlay(xc,mg)
		end
	end
end
