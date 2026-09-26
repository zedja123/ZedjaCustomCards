--
--Build Rider - Misora
--scripted by Zedja
local s,id=GetID()
local SET_BUILD_RIDER=0x1e04
function s.initial_effect(c)
	--If you control only "Build Rider" monsters, you can Special Summon this card (from your hand)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0},EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spproccon)
	c:RegisterEffect(e1)
	--You can target 1 of your banished "Build Rider" monsters and 1 card in your opponent's GY; banish this card from your GY and that card in your opponent's GY, and if you do, Special Summon that "Build Rider" monster, but negate its effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_BUILD_RIDER}
function s.nonriderfilter(c)
	return c:IsFacedown() or not c:IsSetCard(SET_BUILD_RIDER)
end
function s.spproccon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		and not Duel.IsExistingMatchingCard(s.nonriderfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_BUILD_RIDER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	if chk==0 then return c:IsAbleToRemove() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
	e:SetLabelObject(sc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rc=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,Group.FromCards(c,rc),2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sc,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sc=e:GetLabelObject()
	local tg=Duel.GetTargetCards(e)
	local rc=(tg-sc):GetFirst()
	if not (c:IsRelateToEffect(e) and rc and rc:IsRelateToEffect(e)) then return end
	if Duel.Remove(Group.FromCards(c,rc),POS_FACEUP,REASON_EFFECT)==2
		and sc and sc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		--Negate its effects
		sc:NegateEffects(c)
	end
	Duel.SpecialSummonComplete()
end
