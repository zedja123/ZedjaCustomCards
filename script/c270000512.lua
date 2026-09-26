--
--Milacresy Essence - Layah
--scripted by Zedja
--revised by Whispered
local s,id=GetID()
local SET_MILACRESY=0xe05
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeSynchroSummoned()
	--Synchro Summon procedure: 1+ "Milacresy" Tuners + 1+ non-Tuner "Milacresy" monsters
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_MILACRESY),1,99,Synchro.NonTunerEx2(s.nontunerfilter),1,99,s.lnktunerfilter,nil,s.tunerreq)
	--For this card's Synchro Summon, you can treat 1 "Milacresy" Link Monster you control as a Tuner with a Level equal to its Link Rating
	for lk=1,6 do
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e0:SetCode(EFFECT_SYNCHRO_LEVEL)
		e0:SetRange(LOCATION_EXTRA)
		e0:SetTargetRange(LOCATION_MZONE,0)
		e0:SetTarget(function(e,c) return c:IsSetCard(SET_MILACRESY) and c:IsLink(lk) end)
		e0:SetValue(lk)
		c:RegisterEffect(e0)
	end
	local e0b=Effect.CreateEffect(c)
	e0b:SetType(EFFECT_TYPE_FIELD)
	e0b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0b:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e0b:SetRange(LOCATION_EXTRA)
	e0b:SetTargetRange(LOCATION_MZONE,0)
	e0b:SetTarget(function(e,c) return c:IsSetCard(SET_MILACRESY) and c:IsLinkMonster() end)
	e0b:SetValue(function(e,sc) return sc and not sc:IsSetCard(SET_MILACRESY) end)
	c:RegisterEffect(e0b)
	--If this card is Synchro Summoned: You can look at the top 3 cards of your opponent's Deck, and if you do, place them on top of their Deck in any order
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetTarget(s.sorttg)
	e1:SetOperation(s.sortop)
	c:RegisterEffect(e1)
	--(Quick Effect): You can target 1 face-up monster on the field; negate its effects, and if you do, destroy it
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_MILACRESY}
function s.lnktunerfilter(c,sc,sumtype,tp)
	return c:IsSetCard(SET_MILACRESY,sc,sumtype,tp) and c:IsLinkMonster()
end
function s.nontunerfilter(c,sc,sumtype,tp)
	return c:IsSetCard(SET_MILACRESY,sc,sumtype,tp) and not c:IsLinkMonster()
end
function s.tunerreq(g,sc,tp)
	return g:FilterCount(Card.IsLinkMonster,nil)<=1
end
function s.sorttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=3 end
end
function s.sortop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)<3 then return end
	Duel.SortDecktop(tp,1-tp,3)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsNegatableMonster() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatableMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local g=Duel.SelectTarget(tp,Card.IsNegatableMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e)) then return end
	--Negate its effects, and if you do, destroy it
	tc:NegateEffects(e:GetHandler(),nil,true)
	Duel.AdjustInstantly(tc)
	if tc:IsDisabled() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
